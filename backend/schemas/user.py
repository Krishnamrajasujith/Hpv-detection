from pydantic import BaseModel, EmailStr, Field


class UserProfile(BaseModel):
    id: int
    username: str
    email: str
    mobile: str
    role: str

    model_config = {"from_attributes": True}


class UpdateProfileRequest(BaseModel):
    email: EmailStr | None = None
    mobile: str | None = Field(default=None, max_length=20)
