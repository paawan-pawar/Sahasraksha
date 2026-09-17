from __future__ import annotations

from dataclasses import dataclass
from math import sqrt

from .camera_graph import CameraGraph
from .models import Observation


@dataclass(frozen=True)
class MatchResult:
    matched: bool
    confidence: float
    evidence: dict[str, float | bool | str]


def cosine_similarity(left: list[float], right: list[float]) -> float:
    if not left or not right or len(left) != len(right):
        return 0.0
    dot = sum(a * b for a, b in zip(left, right))
    magnitude = sqrt(sum(a * a for a in left) * sum(b * b for b in right))
    return max(0.0, min(1.0, dot / magnitude)) if magnitude else 0.0


class CrossCameraMatcher:
    def __init__(self, graph: CameraGraph, threshold: float = 0.62) -> None:
        self.graph = graph
        self.threshold = threshold

    def score(self, previous: Observation, current: Observation) -> MatchResult:
        elapsed = (current.timestamp - previous.timestamp).total_seconds()
        appearance = cosine_similarity(previous.appearance, current.appearance)
        connected = self.graph.has_connection(previous.camera_id, current.camera_id)
        edge = next((edge for edge in self.graph.next_connections(previous.camera_id) if edge.destination == current.camera_id), None)
        travel = 0.0
        if edge and edge.max_travel_seconds >= elapsed >= edge.min_travel_seconds:
            travel = 1.0
        elif edge:
            travel = max(0.0, 1.0 - min(abs(elapsed - edge.min_travel_seconds), abs(elapsed - edge.max_travel_seconds)) / max(edge.max_travel_seconds, 1))
        type_match = previous.entity_type == current.entity_type
        confidence = 0.45 * appearance + 0.2 * float(connected) + 0.2 * travel + 0.15 * float(type_match)
        return MatchResult(confidence >= self.threshold, confidence, {
            "appearance_similarity": appearance,
            "time_consistency": travel,
            "camera_connected": connected,
            "entity_type_match": type_match,
            "from_camera": previous.camera_id,
            "to_camera": current.camera_id,
        })
