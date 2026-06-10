from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session

from backend.database import get_db
from backend.models.user import User
from backend.models.audit_log import AuditLog
from backend.schemas.user import UserProfile, UpdateProfileRequest
from backend.services.auth_service import get_current_user

router = APIRouter(prefix="/api/users", tags=["users"])


def _log(db: Session, username: str, action: str, detail: str, ip: str):
    db.add(AuditLog(username=username, action=action, detail=detail, ip=ip))
    db.commit()


@router.get("/me", response_model=UserProfile)
def get_profile(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.username == current_user["sub"]).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.patch("/me", response_model=UserProfile)
def update_profile(
    body: UpdateProfileRequest,
    request: Request,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.username == current_user["sub"]).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if body.email is not None:
        user.email = body.email
    if body.mobile is not None:
        user.mobile = body.mobile

    db.commit()
    db.refresh(user)
    _log(db, user.username, "PROFILE_UPDATE", "Profile updated", request.client.host if request.client else "")
    return user
