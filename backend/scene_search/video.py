from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Protocol


@dataclass(frozen=True)
class CameraSource:
    camera_id: str
    source: str
    zone: str | None = None
    camera_name: str | None = None
    sample_fps: float = 2.0


class EventExtractor(Protocol):
    def process_frame(self, frame: object, source: CameraSource, frame_number: int, timestamp: object) -> list[object]: ...


class VideoProcessor:
    """OpenCV sampling loop; detector/attribute/OCR extraction is injected."""

    def __init__(self, extractor: EventExtractor) -> None:
        self.extractor = extractor

    def process(self, source: CameraSource) -> int:
        import cv2
        path = Path(source.source)
        capture = cv2.VideoCapture(str(path) if path.exists() else source.source)
        if not capture.isOpened():
            raise FileNotFoundError(f"Unable to open camera source: {source.source}")
        source_fps = capture.get(cv2.CAP_PROP_FPS) or 25.0
        stride = max(1, round(source_fps / max(source.sample_fps, 0.1)))
        processed = 0
        frame_number = 0
        while True:
            ok, frame = capture.read()
            if not ok:
                break
            if frame_number % stride == 0:
                timestamp = frame_number / source_fps
                self.extractor.process_frame(frame, source, frame_number, timestamp)
                processed += 1
            frame_number += 1
        capture.release()
        return processed
