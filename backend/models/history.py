from sqlalchemy import Column, Integer, String, Float, DateTime, func
from backend.database import Base


class History(Base):
    __tablename__ = "history"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, index=True, nullable=False)
    patient_name = Column(String, nullable=False)
    age = Column(String)
    gender = Column(String)
    sample_id = Column(String)
    test_date = Column(String)
    result = Column(String)
    confidence = Column(Float)
    risk = Column(String)
    notes = Column(String, default="")
    next_visit_date = Column(String, default="")
    daily_food_intake = Column(String, default="")
    image = Column(String, default="")
    created_at = Column(DateTime, server_default=func.now())
