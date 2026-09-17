from __future__ import annotations

from collections import defaultdict
from math import hypot
from .models import GlobalEntity, Observation


class TrajectoryManager:
    def history(self, entity: GlobalEntity) -> list[Observation]:
        return sorted(entity.observations, key=lambda item: item.timestamp)

    def camera_sequence(self, entity: GlobalEntity) -> list[str]:
        sequence: list[str] = []
        for observation in self.history(entity):
            if not sequence or sequence[-1] != observation.camera_id:
                sequence.append(observation.camera_id)
        return sequence

    def transitions(self, entity: GlobalEntity) -> list[dict[str, object]]:
        observations = self.history(entity)
        result = []
        for previous, current in zip(observations, observations[1:]):
            if previous.camera_id != current.camera_id:
                result.append({
                    "from_camera": previous.camera_id,
                    "to_camera": current.camera_id,
                    "timestamp": current.timestamp.isoformat(),
                    "travel_seconds": (current.timestamp - previous.timestamp).total_seconds(),
                })
        return result

    def metrics(self, entity: GlobalEntity) -> dict[str, object]:
        observations = self.history(entity)
        speeds: list[float] = []
        for previous, current in zip(observations, observations[1:]):
            if previous.camera_id != current.camera_id:
                continue
            elapsed = (current.timestamp - previous.timestamp).total_seconds()
            if elapsed <= 0 or previous.ground_position is None or current.ground_position is None:
                continue
            distance = hypot(
                current.ground_position[0] - previous.ground_position[0],
                current.ground_position[1] - previous.ground_position[1],
            )
            speeds.append(distance / elapsed)
        dwell: dict[str, float] = defaultdict(float)
        for previous, current in zip(observations, observations[1:]):
            if previous.camera_id == current.camera_id:
                dwell[previous.camera_id] += max(0, (current.timestamp - previous.timestamp).total_seconds())
        return {"average_speed_mps": sum(speeds) / len(speeds) if speeds else None, "dwell_seconds": dict(dwell)}

    def response(self, entity: GlobalEntity) -> dict[str, object]:
        return {
            "global_id": entity.global_id,
            "camera_sequence": self.camera_sequence(entity),
            "observations": [item.to_dict() for item in self.history(entity)],
            "transitions": self.transitions(entity),
            "metrics": self.metrics(entity),
        }
