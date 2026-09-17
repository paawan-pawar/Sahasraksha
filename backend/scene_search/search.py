from __future__ import annotations

from datetime import datetime
from .database import EventRepository
from .models import Event, ParsedQuery, SearchResult
from .vector_index import VectorIndex


class HybridSearchEngine:
    def __init__(self, repository: EventRepository, vector_index: VectorIndex | None = None) -> None:
        self.repository = repository
        self.vector_index = vector_index or VectorIndex()
        self.weights = {"semantic": 0.45, "attribute": 0.25, "object": 0.15, "zone": 0.10, "temporal": 0.05}

    def index(self, event: Event) -> None:
        self.repository.upsert(event)
        self.vector_index.add(event)

    def search(self, parsed: ParsedQuery, top_k: int = 50, threshold: float = 0.0) -> tuple[list[SearchResult], int]:
        filters = parsed.filters.model_dump(exclude_none=True)
        exact = {
            key: value
            for key, value in filters.items()
            if key in {"camera_id", "zone", "object_type", "vehicle_type", "plate_number", "shirt_color", "vehicle_color"}
        }
        if exact.get("object_type") == "vehicle" and exact.get("vehicle_type"):
            exact.pop("object_type", None)

        candidates = self.repository.search(exact)
        if not candidates and ("vehicle_type" in exact or "object_type" in exact or "camera_id" in exact):
            candidates = self.repository.all()

        ranked = [(event, self._score(event, parsed)) for event in candidates if self._matches_time(event, parsed)]
        ranked.sort(key=lambda item: (item[1], item[0].timestamp), reverse=True)
        results = [self._result(event, score) for event, score in ranked if score >= threshold][:top_k]
        return results, len(ranked)

    def _score(self, event: Event, parsed: ParsedQuery) -> float:
        filters = parsed.filters
        attribute_values = []
        if filters.shirt_color:
            attribute_values.append(event.shirt_color == filters.shirt_color)
        if filters.vehicle_color:
            attribute_values.append(event.vehicle_color == filters.vehicle_color)
        if filters.vehicle_type:
            attribute_values.append(event.vehicle_type == filters.vehicle_type or event.object_type == filters.vehicle_type)
        known_attributes = [value for value in attribute_values if value is not None]
        attribute_match = sum(bool(value) for value in known_attributes) / len(known_attributes) if known_attributes else 1.0
        object_match = 1.0 if not filters.object_type or filters.object_type == event.object_type or (filters.object_type == "vehicle" and event.object_type in {"car", "suv", "truck", "bus", "motorcycle", "bicycle", "vehicle"}) else 0.0
        zone_match = 1.0 if not filters.zone or (event.zone and filters.zone.lower() in event.zone.lower()) else 0.0
        temporal = 1.0 if self._matches_time(event, parsed) else 0.0
        semantic = self._semantic_score(event, parsed.filters.semantic_terms)
        return self.weights["semantic"] * semantic + self.weights["attribute"] * attribute_match + self.weights["object"] * object_match + self.weights["zone"] * zone_match + self.weights["temporal"] * temporal

    @staticmethod
    def _semantic_score(event: Event, terms: list[str]) -> float:
        if not terms:
            return 1.0
        haystack = " ".join(str(value or "") for value in [event.object_type, event.zone, event.camera_id, event.location, event.direction, event.vehicle_type, event.vehicle_color, event.shirt_color]).lower()
        return sum(term in haystack for term in terms) / len(terms)

    @staticmethod
    def _matches_time(event: Event, parsed: ParsedQuery) -> bool:
        filters = parsed.filters
        if filters.date and event.timestamp.date().isoformat() != filters.date:
            return False
        if filters.start_time and filters.end_time:
            current = event.timestamp.hour * 60 + event.timestamp.minute
            start_hour, start_minute = map(int, filters.start_time.split(":"))
            end_hour, end_minute = map(int, filters.end_time.split(":"))
            start, end = start_hour * 60 + start_minute, end_hour * 60 + end_minute
            if not (start <= current <= end):
                return False
        if filters.time_period == "night" and not (event.timestamp.hour >= 18 or event.timestamp.hour < 6):
            return False
        if filters.time_period == "day" and not (6 <= event.timestamp.hour < 18):
            return False
        return True

    @staticmethod
    def _result(event: Event, score: float) -> SearchResult:
        return SearchResult(event_id=event.event_id, camera_id=event.camera_id, zone=event.zone, timestamp=event.timestamp, object_type=event.object_type, bbox=event.bbox, similarity=round(score, 4), detection_confidence=event.detection_confidence, thumbnail_url=event.thumbnail_path, full_frame_url=event.full_frame_path, clip_url=event.clip_path, attributes={"shirt_color": event.shirt_color, "vehicle_type": event.vehicle_type, "vehicle_color": event.vehicle_color, "plate_number": event.plate_number, "plate_confidence": event.plate_confidence})
