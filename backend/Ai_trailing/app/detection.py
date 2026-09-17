from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from typing import Any

from .core.models import BoundingBox, EntityType


@dataclass(frozen=True)
class Detection:
    camera_id: str
    timestamp: datetime
    entity_type: EntityType
    bbox: BoundingBox
    confidence: float
    frame_index: int


class Yolo11Detector:
    """YOLO11 adapter. Model loading is explicit so API startup does not fake detections."""

    def __init__(self, model_path: str = "yolo11x.pt", confidence: float = 0.35) -> None:
        self.model_path = model_path
        self.confidence = confidence
        self._model: Any = None

    def load(self) -> None:
        from ultralytics import YOLO
        self._model = YOLO(self.model_path)

    def detect(self, frame: Any, camera_id: str, timestamp: datetime, frame_index: int) -> list[Detection]:
        if self._model is None:
            raise RuntimeError("Detector is not loaded. Call load() after installing model dependencies.")
        results = self._model.predict(frame, conf=self.confidence, verbose=False)
        detections: list[Detection] = []
        allowed = {0: "person", 2: "car", 3: "motorcycle", 5: "bus", 7: "truck"}
        for result in results:
            for box in result.boxes:
                class_id = int(box.cls[0])
                entity_type = allowed.get(class_id)
                if entity_type is None:
                    continue
                x1, y1, x2, y2 = [float(value) for value in box.xyxy[0]]
                detections.append(Detection(camera_id, timestamp, entity_type, BoundingBox(x1, y1, x2, y2), float(box.conf[0]), frame_index))
        return detections
