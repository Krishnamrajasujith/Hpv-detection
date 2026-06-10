import os
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from dotenv import load_dotenv

_here = os.path.dirname(os.path.abspath(__file__))
load_dotenv(os.path.join(_here, ".env"), override=True)

from backend.database import init_db
from backend.routers import auth, users, predictions, admin
from backend.services.ml_service import auto_train_if_needed


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    auto_train_if_needed()
    yield


app = FastAPI(
    title="HPV DetectAI API",
    description="Genomic diagnostics platform for HPV16 detection",
    version="2.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        os.getenv("FRONTEND_URL", "http://localhost:5173"),   # React Vite
        os.getenv("MOBILE_URL", "http://localhost:3000"),
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

_static_dir = os.getenv("STATIC_ROOT", os.path.join(os.path.dirname(__file__), "static"))
os.makedirs(_static_dir, exist_ok=True)
app.mount("/static", StaticFiles(directory=_static_dir), name="static")

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(predictions.router)
app.include_router(admin.router)


@app.get("/")
def health():
    return {"status": "ok", "service": "HPV DetectAI API v2"}
