from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import yaml

from .database import EventRepository
from .models import BoundingBox, Event


class CameraVideoScanner:
    """Offline demo scanner: reads every configured camera to EOF and indexes YOLO detections."""

    classes = {0: "person", 1: "bicycle", 2: "car", 3: "motorcycle", 5: "bus", 7: "truck"}

    def __init__(self, repository: EventRepository, model_name: str = "yolo11n.pt") -> None:
        self.repository = repository
        self.model_name = model_name

    def scan_config(self, config_path: str | Path, sample_fps: float = 2.0) -> dict[str, Any]:
        try:
            from ultralytics import YOLO
        except ImportError as error:
            raise RuntimeError("ultralytics is not installed; install scene_search/requirements.txt") from error
        import cv2
        media_dir = Path(__file__).resolve().parents[1] / "data" / "media"
        media_dir.mkdir(parents=True, exist_ok=True)

        config_file = Path(config_path)
        config = yaml.safe_load(config_file.read_text(encoding="utf-8")) or {}
        model = YOLO(self.model_name)
        camera_stats = []
        for camera_id, camera in config.get("cameras", {}).items():
            source = Path(camera["source"])
            if not source.is_absolute():
                source = (config_file.parent / source).resolve()
            if not source.exists():
                camera_stats.append({"camera_id": camera_id, "status": "missing", "events": 0})
                continue
            capture = cv2.VideoCapture(str(source))
            fps = capture.get(cv2.CAP_PROP_FPS) or 25.0
            # Only process frames at the requested sample rate instead of every frame.
            frame_interval = max(1, int(fps / sample_fps))
            frame_number = 0
            event_count = 0
            while True:
                ok, frame = capture.read()
                if not ok:
                    break
                if frame_number % frame_interval != 0:
                    frame_number += 1
                    continue
                result = model.predict(frame, verbose=False)[0]
                for index, box in enumerate(result.boxes):
                    class_id = int(box.cls[0])
                    object_type = self.classes.get(class_id)
                    if object_type is None:
                        continue
                    x1, y1, x2, y2 = [float(value) for value in box.xyxy[0]]
                    event = Event(
                        event_id=f"{camera_id}-{frame_number}-{index}",
                        camera_id=camera_id,
                        zone=camera.get("zone"),
                        timestamp=datetime.fromtimestamp(frame_number / fps, tz=timezone.utc),
                        frame_number=frame_number,
                        object_type=object_type,
                        detection_confidence=float(box.conf[0]),
                        bbox=BoundingBox(x1=x1, y1=y1, x2=x2, y2=y2),
                        thumbnail_path=f"/media/{camera_id}-{frame_number}-{index}.jpg",
                        full_frame_path=f"/media/{camera_id}-{frame_number}-{index}-full.jpg",
                        clip_path=str(source),
                    )
                    frame_name = f"{camera_id}-{frame_number}-{index}"
                    cv2.imwrite(str(media_dir / f"{frame_name}-full.jpg"), frame)
                    crop = frame[max(0, int(y1)):min(frame.shape[0], int(y2)), max(0, int(x1)):min(frame.shape[1], int(x2))]
                    if crop.size:
                        cv2.imwrite(str(media_dir / f"{frame_name}.jpg"), crop)
                    self.repository.upsert(event)
                    event_count += 1
                frame_number += 1
            capture.release()
            camera_stats.append({"camera_id": camera_id, "status": "scanned", "frames": frame_number, "events": event_count})
        return {"status": "complete", "cameras": camera_stats, "events": sum(item.get("events", 0) for item in camera_stats)}

