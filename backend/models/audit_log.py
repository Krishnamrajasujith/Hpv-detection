from sqlalchemy import Column, Integer, String, DateTime, func
from backend.database import Base


class AuditLog(Base):
    __tablename__ = "audit_log"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, index=True)
    action = Column(String)
    detail = Column(String, default="")
    ip = Column(String, default="")
    created_at = Column(DateTime, server_default=func.now())
