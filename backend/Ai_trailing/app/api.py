from __future__ import annotations

from pathlib import Path
from fastapi import APIRouter, HTTPException, WebSocket, WebSocketDisconnect

from .core.camera_graph import CameraGraph
from .core.predictor import MarkovCameraPredictor
from .core.trajectory import TrajectoryManager
from .store import TrackingStore


class TrackingAPI:
    def __init__(self, store: TrackingStore, graph: CameraGraph) -> None:
        self.store = store
        self.graph = graph
        self.trajectory = TrajectoryManager()
        self.predictor = MarkovCameraPredictor(graph)
        self.router = APIRouter()
        self._register_routes()

    def _register_routes(self) -> None:
        @self.router.get("/entities")
        def entities() -> list[dict]:
            return [entity.to_dict() for entity in self.store.all()]

        @self.router.get("/entities/{global_id}")
        def entity(global_id: str) -> dict:
            found = self.store.get(global_id)
            if found is None:
                raise HTTPException(status_code=404, detail="Global entity not found")
            return found.to_dict()

        @self.router.get("/entities/{global_id}/trajectory")
        def trajectory(global_id: str) -> dict:
            found = self.store.get(global_id)
            if found is None:
                raise HTTPException(status_code=404, detail="Global entity not found")
            return self.trajectory.response(found)

        @self.router.get("/entities/{global_id}/history")
        def history(global_id: str) -> list[dict]:
            found = self.store.get(global_id)
            if found is None:
                raise HTTPException(status_code=404, detail="Global entity not found")
            return [observation.to_dict() for observation in self.trajectory.history(found)]

        @self.router.get("/entities/{global_id}/prediction")
        def prediction(global_id: str) -> list[dict]:
            found = self.store.get(global_id)
            if found is None:
                raise HTTPException(status_code=404, detail="Global entity not found")
            self.predictor.learn(self.store.all())
            return [item.to_dict() for item in self.predictor.predict(found)]

        @self.router.get("/cameras")
        def cameras() -> dict:
            return self.graph.to_dict()

        @self.router.get("/cameras/{camera_id}/connections")
        def connections(camera_id: str) -> list[dict]:
            return [edge.__dict__ for edge in self.graph.next_connections(camera_id)]


def create_api(store: TrackingStore, config_path: str | Path) -> TrackingAPI:
    return TrackingAPI(store, CameraGraph.from_config(config_path))


class WebSocketHub:
    def __init__(self) -> None:
        self.clients: set[WebSocket] = set()

    async def connect(self, websocket: WebSocket) -> None:
        await websocket.accept()
        self.clients.add(websocket)

    def disconnect(self, websocket: WebSocket) -> None:
        self.clients.discard(websocket)

    async def publish(self, message: dict) -> None:
        for client in list(self.clients):
            try:
                await client.send_json(message)
            except Exception:
                self.disconnect(client)
