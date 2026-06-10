import socket
from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session

from backend.database import get_db
from backend.models.user import User
from backend.models.audit_log import AuditLog
from backend.schemas.auth import (
    LoginRequest, RegisterRequest, VerifyOTPRequest,
    ForgotPasswordRequest, ResetPasswordRequest,
    TokenResponse, OTPResponse,
)
from backend.services.auth_service import hash_password, verify_password, create_access_token
from backend.services.email_service import generate_otp, verify_otp, send_otp_email

router = APIRouter(prefix="/api/auth", tags=["auth"])

# Pending registrations: {email: {username, password_hash, mobile}}
_pending_registrations: dict[str, dict] = {}


def _log(db: Session, username: str, action: str, detail: str, ip: str):
    db.add(AuditLog(username=username, action=action, detail=detail, ip=ip))
    db.commit()


def _ip(request: Request) -> str:
    return request.client.host if request.client else "unknown"


@router.post("/login", response_model=TokenResponse)
def login(body: LoginRequest, request: Request, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == body.username).first()
    if not user or not verify_password(body.password, user.password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    token = create_access_token({"sub": user.username, "role": user.role})
    _log(db, user.username, "LOGIN", "Successful login", _ip(request))
    return TokenResponse(access_token=token, username=user.username, role=user.role)


@router.post("/register", response_model=OTPResponse, status_code=201)
def register(body: RegisterRequest, request: Request, db: Session = Depends(get_db)):
    if db.query(User).filter(User.username == body.username).first():
        raise HTTPException(status_code=400, detail="Username already taken")
    if db.query(User).filter(User.email == body.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")

    _pending_registrations[body.email] = {
        "username": body.username,
        "password_hash": hash_password(body.password),
        "mobile": body.mobile,
    }

    otp = generate_otp(body.email)
    sent = send_otp_email(body.email, otp, "registration")
    _log(db, body.username, "REGISTER", f"OTP requested for {body.email}", _ip(request))

    return OTPResponse(
        message="OTP sent. Please verify your email.",
        dev_otp=otp if not sent else None,
    )


@router.post("/verify-otp")
def verify_otp_endpoint(body: VerifyOTPRequest, request: Request, db: Session = Depends(get_db)):
    ok, msg = verify_otp(body.email, body.otp)
    if not ok:
        raise HTTPException(status_code=400, detail=msg)

    if body.purpose == "register":
        pending = _pending_registrations.pop(body.email, None)
        if not pending:
            raise HTTPException(status_code=400, detail="Registration session expired. Please register again.")

        user = User(
            username=pending["username"],
            password=pending["password_hash"],
            email=body.email,
            mobile=pending.get("mobile", ""),
            role="user",
        )
        db.add(user)
        db.commit()
        _log(db, pending["username"], "REGISTER", "Account created after OTP", _ip(request))
        return {"message": "Account created successfully. You can now log in."}

    return {"message": "OTP verified. Proceed to reset password."}


@router.post("/forgot-password", response_model=OTPResponse)
def forgot_password(body: ForgotPasswordRequest, request: Request, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == body.email).first()
    # Generic response to avoid email enumeration
    if not user:
        return OTPResponse(message="If that email is registered, an OTP has been sent.")

    otp = generate_otp(body.email)
    sent = send_otp_email(body.email, otp, "password reset")
    _log(db, user.username, "PASSWORD_RESET", "Reset OTP requested", _ip(request))

    return OTPResponse(
        message="OTP sent to your email.",
        dev_otp=otp if not sent else None,
    )


@router.post("/reset-password")
def reset_password(body: ResetPasswordRequest, request: Request, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == body.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.password = hash_password(body.password)
    db.commit()
    _log(db, user.username, "PASSWORD_RESET", "Password updated", _ip(request))
    return {"message": "Password reset successfully."}


@router.post("/logout")
def logout():
    # JWT is stateless — client discards the token
    return {"message": "Logged out."}


@router.get("/validate-email")
def validate_email(email: str, db: Session = Depends(get_db)):
    """Check email format, domain reachability, and registration status."""
    if "@" not in email or "." not in email.split("@")[-1]:
        return {"valid": False, "reason": "Invalid email format"}

    domain = email.split("@")[-1].lower()

    # Check domain resolves (basic reachability check)
    try:
        socket.getaddrinfo(domain, None, socket.AF_INET)
    except socket.gaierror:
        return {"valid": False, "reason": "Email domain does not exist"}

    # Check if already registered
    if db.query(User).filter(User.email == email).first():
        return {"valid": False, "reason": "Email is already registered"}

    return {"valid": True, "reason": ""}
