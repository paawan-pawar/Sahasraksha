from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from .detection import Detection


@dataclass(frozen=True)
class LocalTrack:
    local_track_id: int
    detection: Detection


class ByteTrackTracker:
    """Ultralytics ByteTrack adapter. IDs are intentionally scoped to one camera."""

    def __init__(self, tracker_config: str = "bytetrack.yaml") -> None:
        self.tracker_config = tracker_config

    def update(self, frame: Any, detector: Any, camera_id: str, timestamp: Any, frame_index: int) -> list[LocalTrack]:
        results = detector._model.track(frame, persist=True, tracker=self.tracker_config, verbose=False)
        tracks: list[LocalTrack] = []
        for result in results:
            for box in result.boxes:
                if box.id is None:
                    continue
                detection = detector.detect(frame, camera_id, timestamp, frame_index)
                if detection:
                    tracks.append(LocalTrack(int(box.id[0]), detection[0]))
        return tracks
