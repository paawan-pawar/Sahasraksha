from __future__ import annotations

from pathlib import Path
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from .api import create_api
from .settings import cors_origins, path_from_env

DATABASE_PATH = path_from_env("SCENE_SEARCH_DATABASE", "data/scene_search.db")
DATABASE_PATH.parent.mkdir(parents=True, exist_ok=True)
MEDIA_PATH = DATABASE_PATH.parent / "media"
MEDIA_PATH.mkdir(parents=True, exist_ok=True)
api = create_api(str(DATABASE_PATH))
app = FastAPI(title="IBVAP Scene Intelligence Search API", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins("SCENE_SEARCH_CORS_ORIGINS", "http://localhost:64048,http://localhost:8080,http://127.0.0.1:8080"),
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.mount("/media", StaticFiles(directory=MEDIA_PATH), name="media")
app.include_router(api.router)


@app.get("/")
def root() -> dict[str, str]:
    return {"service": "IBVAP Scene Intelligence Search API", "docs": "/docs", "health": "/health"}


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "index": "ready", "data_mode": "indexed-events-only"}
