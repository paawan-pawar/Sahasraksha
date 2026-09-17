from __future__ import annotations

from fastapi import APIRouter, HTTPException
from .database import EventRepository
from .models import Event, ProcessVideoRequest, ScanCamerasRequest, SearchHistoryItem, SearchRequest, SearchResponse
from .query_parser import SceneQueryParser
from .search import HybridSearchEngine


class SceneSearchAPI:
    def __init__(self, database_path: str = "scene_search.db") -> None:
        self.repository = EventRepository(database_path)
        self.engine = HybridSearchEngine(self.repository)
        self.parser = SceneQueryParser()
        self.router = APIRouter()
        self._register()

    def _register(self) -> None:
        @self.router.post("/events", response_model=Event)
        def index_event(event: Event) -> Event:
            self.engine.index(event)
            return event

        @self.router.post("/process/video")
        def process_video(request: ProcessVideoRequest) -> dict[str, object]:
            """Validate a source and expose the sampling contract for an extractor worker.

            Detection, tracking, attributes, OCR, and embedding models are injected into
            VideoProcessor outside the HTTP request so a web request cannot fabricate events.
            """
            from pathlib import Path
            source_path = Path(request.source)
            if not source_path.exists() and not request.source.lower().startswith(("rtsp://", "http://", "https://")):
                raise HTTPException(status_code=400, detail="Video source does not exist and is not an RTSP/HTTP URL")
            return {"status": "accepted", "camera_id": request.camera_id, "source": request.source, "sample_fps": request.sample_fps, "next_step": "Run VideoProcessor with an injected EventExtractor"}

        @self.router.post("/process/cameras")
        def process_cameras(request: ScanCamerasRequest) -> dict[str, object]:
            from pathlib import Path
            from .scanner import CameraVideoScanner
            try:
                config_path = Path(request.config_path)
                if not config_path.is_absolute():
                    config_path = Path(__file__).resolve().parents[1] / config_path
                return CameraVideoScanner(self.repository, request.model_name).scan_config(config_path, sample_fps=request.sample_fps)
            except (FileNotFoundError, RuntimeError, ValueError) as error:
                raise HTTPException(status_code=503, detail=str(error)) from error

        @self.router.post("/search", response_model=SearchResponse)
        def search(request: SearchRequest) -> SearchResponse:
            parsed = self.parser.parse(request.query)
            results, total = self.engine.search(parsed, request.top_k, request.similarity_threshold)
            self.repository.save_search(request.query, results)
            return SearchResponse(parsed_query=parsed, results=results, total_candidates=total)

        @self.router.get("/search/history", response_model=list[SearchHistoryItem])
        def search_history() -> list[SearchHistoryItem]:
            return self.repository.search_history()

        @self.router.get("/events/{event_id}", response_model=Event)
        def event(event_id: str) -> Event:
            result = self.repository.get(event_id)
            if result is None:
                raise HTTPException(status_code=404, detail="Event not found")
            return result

        @self.router.get("/events/{event_id}/clip")
        def clip(event_id: str) -> dict[str, str | None]:
            result = self.repository.get(event_id)
            if result is None:
                raise HTTPException(status_code=404, detail="Event not found")
            return {"event_id": event_id, "clip_path": result.clip_path}

        @self.router.get("/cameras")
        def cameras() -> list[dict[str, str | None]]:
            rows = self.repository.connection.execute("SELECT DISTINCT camera_id, camera_name, location, zone FROM events ORDER BY camera_id").fetchall()
            return [dict(row) for row in rows]

        @self.router.get("/zones")
        def zones() -> list[str]:
            rows = self.repository.connection.execute("SELECT DISTINCT zone FROM events WHERE zone IS NOT NULL ORDER BY zone").fetchall()
            return [row[0] for row in rows]

        @self.router.get("/statistics")
        def statistics() -> dict[str, int]:
            return {"events": self.repository.connection.execute("SELECT COUNT(*) FROM events").fetchone()[0]}


def create_api(database_path: str) -> SceneSearchAPI:
    return SceneSearchAPI(database_path)
