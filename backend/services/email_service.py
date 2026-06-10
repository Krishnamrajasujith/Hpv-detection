import os
import random
import smtplib
from datetime import datetime, timedelta
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

# In-memory OTP store: {email: {"otp": str, "expires_at": datetime}}
_otp_store: dict[str, dict] = {}

_EMAIL_TEMPLATE = """\
<!DOCTYPE html>
<html>
<head>
  <style>
    body {{ background:#070d1a; font-family:'DM Sans',Arial,sans-serif; color:#b0c4de; margin:0; padding:0; }}
    .wrap {{ max-width:480px; margin:40px auto; background:#0d1a2e; border-radius:12px;
             border:1px solid #1e3a5f; padding:32px; }}
    .logo {{ font-size:22px; font-weight:700; color:#3d7fff; margin-bottom:8px; }}
    .sub {{ color:#00c6ff; font-size:13px; margin-bottom:24px; }}
    .otp {{ font-size:36px; font-weight:700; letter-spacing:10px; color:#0ee7b0;
            background:#0a1628; padding:16px 24px; border-radius:8px;
            border:1px solid #1e3a5f; display:inline-block; margin:16px 0; }}
    .note {{ font-size:12px; color:#5a7a9a; margin-top:16px; }}
  </style>
</head>
<body>
  <div class="wrap">
    <div class="logo">HPV DetectAI</div>
    <div class="sub">Genomic Diagnostics Platform</div>
    <p>Your one-time password for <strong>{purpose}</strong>:</p>
    <div class="otp">{otp}</div>
    <p class="note">This OTP expires in <strong>10 minutes</strong>. Do not share it.</p>
  </div>
</body>
</html>
"""


def generate_otp(email: str) -> str:
    otp = str(random.randint(100000, 999999))
    _otp_store[email] = {"otp": otp, "expires_at": datetime.utcnow() + timedelta(minutes=10)}
    return otp


def verify_otp(email: str, otp: str) -> tuple[bool, str]:
    entry = _otp_store.get(email)
    if not entry:
        return False, "No OTP requested for this email."
    if datetime.utcnow() > entry["expires_at"]:
        _otp_store.pop(email, None)
        return False, "OTP has expired. Please request a new one."
    if entry["otp"] != otp:
        return False, "Incorrect OTP."
    _otp_store.pop(email, None)
    return True, "OTP verified."


def send_otp_email(to_email: str, otp: str, purpose: str = "verification") -> bool:
    """Send OTP via Gmail SMTP. Returns True if sent, False if dev mode."""
    smtp_user = os.getenv("SMTP_USER", "")
    smtp_pass = os.getenv("SMTP_PASS", "")
    if not smtp_user or not smtp_pass:
        return False  # dev mode — caller should expose OTP in response

    msg = MIMEMultipart("alternative")
    msg["Subject"] = f"HPV DetectAI — Your OTP: {otp}"
    msg["From"] = smtp_user
    msg["To"] = to_email
    html_body = _EMAIL_TEMPLATE.format(otp=otp, purpose=purpose)
    msg.attach(MIMEText(html_body, "html"))

    try:
        with smtplib.SMTP("smtp.gmail.com", 587) as server:
            server.starttls()
            server.login(smtp_user, smtp_pass)
            server.sendmail(smtp_user, to_email, msg.as_string())
        return True
    except Exception:
        return False
