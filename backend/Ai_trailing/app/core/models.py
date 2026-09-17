from __future__ import annotations

from dataclasses import asdict, dataclass, field
from datetime import datetime
from typing import Any, Literal

EntityType = Literal["person", "car", "motorcycle", "truck", "bus", "vehicle"]


@dataclass(frozen=True)
class BoundingBox:
    x1: float
    y1: float
    x2: float
    y2: float

    @property
    def center(self) -> tuple[float, float]:
        return ((self.x1 + self.x2) / 2, (self.y1 + self.y2) / 2)


@dataclass
class Observation:
    camera_id: str
    local_track_id: int
    entity_type: EntityType
    timestamp: datetime
    bbox: BoundingBox
    confidence: float
    appearance: list[float] = field(default_factory=list)
    ground_position: tuple[float, float] | None = None
    coordinate_space: Literal["ground", "image"] = "image"
    evidence_uri: str | None = None

    def to_dict(self) -> dict[str, Any]:
        data = asdict(self)
        data["timestamp"] = self.timestamp.isoformat()
        data["center_position"] = self.ground_position or self.bbox.center
        return data


@dataclass
class GlobalEntity:
    global_id: str
    entity_type: EntityType
    first_seen: datetime
    last_seen: datetime
    current_camera: str
    current_position: tuple[float, float]
    confidence: float
    observations: list[Observation] = field(default_factory=list)
    appearance_features: list[float] = field(default_factory=list)

    def add_observation(self, observation: Observation) -> None:
        self.observations.append(observation)
        self.observations.sort(key=lambda item: item.timestamp)
        self.first_seen = min(self.first_seen, observation.timestamp)
        self.last_seen = max(self.last_seen, observation.timestamp)
        self.current_camera = observation.camera_id
        self.current_position = observation.ground_position or observation.bbox.center
        if observation.appearance:
            self.appearance_features = observation.appearance

    def to_dict(self) -> dict[str, Any]:
        return {
            "global_id": self.global_id,
            "entity_type": self.entity_type,
            "first_seen": self.first_seen.isoformat(),
            "last_seen": self.last_seen.isoformat(),
            "current_camera": self.current_camera,
            "current_position": self.current_position,
            "confidence": self.confidence,
            "observations": [item.to_dict() for item in self.observations],
        }


@dataclass(frozen=True)
class CameraConnection:
    destination: str
    distance_m: float | None = None
    direction: str | None = None
    min_travel_seconds: float = 0
    max_travel_seconds: float = 300
    destination_zone: str | None = None
    restricted: bool = False


@dataclass
class Prediction:
    predicted_camera: str
    predicted_zone: str | None
    probability: float
    expected_time_seconds: float | None
    alternative_predictions: list[dict[str, Any]] = field(default_factory=list)

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)
