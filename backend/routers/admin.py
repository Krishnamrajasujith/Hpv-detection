from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session

from backend.database import get_db
from backend.models.user import User
from backend.models.history import History
from backend.models.audit_log import AuditLog
from backend.schemas.user import UserProfile
from backend.schemas.prediction import HistoryItem
from backend.services.auth_service import require_admin

router = APIRouter(prefix="/api/admin", tags=["admin"])


def _log(db: Session, username: str, action: str, detail: str, ip: str):
    db.add(AuditLog(username=username, action=action, detail=detail, ip=ip))
    db.commit()


@router.get("/stats")
def get_stats(
    admin: dict = Depends(require_admin),
    db: Session = Depends(get_db),
):
    total_users = db.query(User).count()
    total_reports = db.query(History).count()
    positive = db.query(History).filter(History.result == "HPV Positive").count()
    negative = db.query(History).filter(History.result == "HPV Negative").count()
    recent = db.query(History).order_by(History.id.desc()).limit(5).all()
    return {
        "total_users": total_users,
        "total_reports": total_reports,
        "positive": positive,
        "negative": negative,
        "recent_reports": [HistoryItem.model_validate(r).model_dump() for r in recent],
    }


@router.get("/users", response_model=list[UserProfile])
def list_users(admin: dict = Depends(require_admin), db: Session = Depends(get_db)):
    return db.query(User).all()


@router.post("/users/{user_id}/upgrade")
def upgrade_user(
    user_id: int,
    request: Request,
    admin: dict = Depends(require_admin),
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.role = "admin"
    db.commit()
    _log(db, admin["sub"], "UPGRADE_USER", f"Upgraded user {user.username} to admin", request.client.host if request.client else "")
    return {"message": f"{user.username} is now an admin."}


@router.delete("/users/{user_id}", status_code=204)
def delete_user(
    user_id: int,
    request: Request,
    admin: dict = Depends(require_admin),
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    db.query(History).filter(History.username == user.username).delete()
    db.delete(user)
    db.commit()
    _log(db, admin["sub"], "DELETE_USER", f"Deleted user {user.username}", request.client.host if request.client else "")


@router.get("/reports", response_model=list[HistoryItem])
def list_reports(admin: dict = Depends(require_admin), db: Session = Depends(get_db)):
    return db.query(History).order_by(History.id.desc()).all()


@router.delete("/reports/{report_id}", status_code=204)
def delete_report(
    report_id: int,
    request: Request,
    admin: dict = Depends(require_admin),
    db: Session = Depends(get_db),
):
    entry = db.query(History).filter(History.id == report_id).first()
    if not entry:
        raise HTTPException(status_code=404, detail="Report not found")
    db.delete(entry)
    db.commit()
    _log(db, admin["sub"], "ADMIN_DELETE_REPORT", f"Deleted report #{report_id}", request.client.host if request.client else "")


@router.get("/audit")
def get_audit(admin: dict = Depends(require_admin), db: Session = Depends(get_db)):
    logs = db.query(AuditLog).order_by(AuditLog.id.desc()).limit(300).all()
    return [
        {
            "id": l.id,
            "username": l.username,
            "action": l.action,
            "detail": l.detail,
            "ip": l.ip,
            "created_at": str(l.created_at),
        }
        for l in logs
    ]
