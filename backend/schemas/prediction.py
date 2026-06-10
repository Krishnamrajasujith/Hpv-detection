from datetime import datetime
from pydantic import BaseModel, Field


class PredictRequest(BaseModel):
    patient_name: str = Field(min_length=1, max_length=100)
    age: str = Field(max_length=10)
    gender: str = Field(max_length=20)
    sample_id: str = Field(max_length=50)
    test_date: str = Field(max_length=20)
    notes: str = Field(default="", max_length=500)
    next_visit_date: str = Field(default="", max_length=20)
    daily_food_intake: str = Field(default="", max_length=1000)


class PredictResponse(BaseModel):
    id: int
    result: str
    confidence: float
    risk: str
    heatmap_url: str
    qr_url: str


class HistoryItem(BaseModel):
    id: int
    username: str
    patient_name: str
    age: str | None
    gender: str | None
    sample_id: str | None
    test_date: str | None
    result: str | None
    confidence: float | None
    risk: str | None
    notes: str | None
    next_visit_date: str | None
    daily_food_intake: str | None
    image: str | None
    created_at: datetime | None

    model_config = {"from_attributes": True}
