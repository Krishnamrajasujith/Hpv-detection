import os
import sys
from fastapi import APIRouter, Depends, File, Form, HTTPException, Request, UploadFile
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session

from backend.database import get_db
from backend.models.history import History
from backend.models.audit_log import AuditLog
from backend.schemas.prediction import PredictResponse, HistoryItem
from backend.services.auth_service import get_current_user
from backend.services.ml_service import detector, get_risk

# write-files utilities are one level up
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "write-files"))
from heatmap_generator import generate_heatmap  # noqa: E402
from qr_generator import generate_qr  # noqa: E402
from pdf_generator import create_pdf  # noqa: E402

BASE_URL = os.getenv("BASE_URL", "http://localhost:8000")
REPORTS_DIR = os.path.join(os.path.dirname(__file__), "..", "static", "reports")
HEATMAPS_DIR = os.path.join(os.path.dirname(__file__), "..", "static", "heatmaps")

router = APIRouter(prefix="/api/predictions", tags=["predictions"])


def _log(db: Session, username: str, action: str, detail: str, ip: str):
    db.add(AuditLog(username=username, action=action, detail=detail, ip=ip))
    db.commit()


@router.post("/train")
async def train_model(
    file: UploadFile = File(...),
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
    request: Request = None,
):
    contents = await file.read()
    result = detector.train_model(contents)
    _log(db, current_user["sub"], "TRAIN", f"Model trained — {result['samples']} samples", request.client.host if request.client else "")
    return {"message": "Model trained successfully.", **result}


@router.post("/predict", response_model=PredictResponse, status_code=201)
async def predict(
    file: UploadFile = File(...),
    patient_name: str = Form(...),
    age: str = Form(...),
    gender: str = Form(...),
    sample_id: str = Form(...),
    test_date: str = Form(...),
    notes: str = Form(default=""),
    next_visit_date: str = Form(default=""),
    daily_food_intake: str = Form(default=""),
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
    request: Request = None,
):
    contents = await file.read()
    confidence, feature_values = detector.predict(contents)
    result, risk = get_risk(confidence)

    heatmap_filename = generate_heatmap(feature_values, current_user["sub"])
    entry = History(
        username=current_user["sub"],
        patient_name=patient_name,
        age=age,
        gender=gender,
        sample_id=sample_id,
        test_date=test_date,
        result=result,
        confidence=round(confidence, 2),
        risk=risk,
        notes=notes,
        next_visit_date=next_visit_date,
        daily_food_intake=daily_food_intake,
        image=heatmap_filename,
    )
    db.add(entry)
    db.commit()
    db.refresh(entry)

    qr_filename = generate_qr(entry.id, BASE_URL)
    _log(db, current_user["sub"], "PREDICT", f"Patient: {patient_name} | {result} ({confidence:.1f}%)", request.client.host if request.client else "")

    return PredictResponse(
        id=entry.id,
        result=result,
        confidence=round(confidence, 2),
        risk=risk,
        heatmap_url=f"{BASE_URL}/static/heatmaps/{heatmap_filename}",
        qr_url=f"{BASE_URL}/static/qr/{qr_filename}",
    )


@router.get("/history", response_model=list[HistoryItem])
def get_history(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return db.query(History).filter(History.username == current_user["sub"]).order_by(History.id.desc()).all()


@router.delete("/history/{report_id}", status_code=204)
def delete_report(
    report_id: int,
    request: Request,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    entry = db.query(History).filter(History.id == report_id, History.username == current_user["sub"]).first()
    if not entry:
        raise HTTPException(status_code=404, detail="Report not found")
    db.delete(entry)
    db.commit()
    _log(db, current_user["sub"], "DELETE_REPORT", f"Deleted report #{report_id}", request.client.host if request.client else "")


@router.get("/download/{report_id}")
def download_pdf(
    report_id: int,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    entry = db.query(History).filter(History.id == report_id).first()
    if not entry:
        raise HTTPException(status_code=404, detail="Report not found")
    if entry.username != current_user["sub"] and current_user.get("role") != "admin":
        raise HTTPException(status_code=403, detail="Access denied")

    pdf_filename = create_pdf({
        "report_id": entry.id,
        "patient_name": entry.patient_name,
        "age": entry.age,
        "gender": entry.gender,
        "sample_id": entry.sample_id,
        "test_date": entry.test_date,
        "result": entry.result,
        "confidence": entry.confidence,
        "risk": entry.risk,
        "notes": entry.notes,
        "next_visit_date": entry.next_visit_date,
        "daily_food_intake": entry.daily_food_intake,
        "heatmap_filename": entry.image,
        "username": entry.username,
    })

    pdf_path = os.path.join(REPORTS_DIR, pdf_filename)
    return FileResponse(pdf_path, media_type="application/pdf", filename=pdf_filename)


@router.get("/qr/{report_id}")
def get_qr(
    report_id: int,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    entry = db.query(History).filter(History.id == report_id).first()
    if not entry:
        raise HTTPException(status_code=404, detail="Report not found")
    qr_filename = f"qr_{report_id}.png"
    qr_path = os.path.join(os.path.dirname(__file__), "..", "static", "qr", qr_filename)
    if not os.path.exists(qr_path):
        generate_qr(report_id, BASE_URL)
    return FileResponse(qr_path, media_type="image/png")


@router.get("/model-status")
def model_status(current_user: dict = Depends(get_current_user)):
    return {"trained": detector.is_trained()}
