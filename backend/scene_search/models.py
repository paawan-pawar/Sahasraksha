from __future__ import annotations

from datetime import datetime
from typing import Any, Literal
from pydantic import BaseModel, Field


class BoundingBox(BaseModel):
    x1: float
    y1: float
    x2: float
    y2: float


class Event(BaseModel):
    event_id: str
    camera_id: str
    camera_name: str | None = None
    location: str | None = None
    zone: str | None = None
    timestamp: datetime
    frame_number: int | None = None
    track_id: int | None = None
    object_type: str
    detection_confidence: float = Field(ge=0, le=1)
    bbox: BoundingBox
    shirt_color: str | None = None
    shirt_color_confidence: float | None = Field(default=None, ge=0, le=1)
    vehicle_type: str | None = None
    vehicle_color: str | None = None
    plate_number: str | None = None
    plate_confidence: float | None = Field(default=None, ge=0, le=1)
    direction: str | None = None
    speed: float | None = None
    dwell_time: float | None = None
    thumbnail_path: str | None = None
    full_frame_path: str | None = None
    clip_path: str | None = None
    embedding: list[float] | None = None


class SearchRequest(BaseModel):
    query: str = Field(min_length=1, max_length=1000)
    top_k: int = Field(default=50, ge=1, le=500)
    similarity_threshold: float = Field(default=0.0, ge=0, le=1)


class ProcessVideoRequest(BaseModel):
    source: str = Field(min_length=1)
    camera_id: str = Field(min_length=1)
    zone: str | None = None
    sample_fps: float = Field(default=2.0, gt=0, le=5)


class ScanCamerasRequest(BaseModel):
    config_path: str = "config/cameras.yaml"
    model_name: str = "yolo11n.pt"
    sample_fps: float = Field(default=2.0, gt=0, le=5)


class SearchFilters(BaseModel):
    object_type: str | None = None
    shirt_color: str | None = None
    vehicle_color: str | None = None
    vehicle_type: str | None = None
    plate_number: str | None = None
    camera_id: str | None = None
    zone: str | None = None
    date: str | None = None
    start_time: str | None = None
    end_time: str | None = None
    time_period: Literal["day", "night"] | None = None
    semantic_terms: list[str] = Field(default_factory=list)


class ParsedQuery(BaseModel):
    filters: SearchFilters
    original_query: str


class SearchResult(BaseModel):
    event_id: str
    camera_id: str
    zone: str | None
    timestamp: datetime
    object_type: str
    bbox: BoundingBox
    similarity: float
    detection_confidence: float
    thumbnail_url: str | None = None
    full_frame_url: str | None = None
    clip_url: str | None = None
    attributes: dict[str, Any] = Field(default_factory=dict)


class SearchResponse(BaseModel):
    parsed_query: ParsedQuery
    results: list[SearchResult]
    total_candidates: int


class SearchHistoryItem(BaseModel):
    search_id: int
    query: str
    searched_at: datetime
    result_count: int
    evidence: list[SearchResult] = Field(default_factory=list)
