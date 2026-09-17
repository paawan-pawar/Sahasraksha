from __future__ import annotations

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware

from .api import WebSocketHub, create_api
from .settings import cors_origins, path_from_env
from .store import TrackingStore

CONFIG_PATH = path_from_env("AI_TRAILING_CONFIG", "config/cameras.yaml")
store = TrackingStore()
tracking_api = create_api(store, CONFIG_PATH)
hub = WebSocketHub()

app = FastAPI(title="IBVAP AI Trailing API", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins("AI_TRAILING_CORS_ORIGINS", "http://localhost:64048,http://localhost:8080,http://127.0.0.1:8080"),
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(tracking_api.router)


@app.get("/")
def root() -> dict[str, str]:
    return {"service": "IBVAP AI Trailing API", "docs": "/docs", "health": "/health"}


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "pipeline": "ready", "data_mode": "live-only"}


@app.websocket("/ws/tracking")
async def tracking_socket(websocket: WebSocket) -> None:
    await hub.connect(websocket)
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        hub.disconnect(websocket)
