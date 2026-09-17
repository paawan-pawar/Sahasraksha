from __future__ import annotations

from dataclasses import dataclass
from math import hypot
from typing import Iterable


@dataclass(frozen=True)
class TrackPoint:
    timestamp: float
    x: float
    y: float
    zone: str | None = None


@dataclass(frozen=True)
class BehaviorFeatures:
    speed: float | None
    direction: str | None
    dwell_time: float
    trajectory_length: float
    zone_transitions: int
    time_of_day: str
    object_count_nearby: int = 0
    group_size: int = 1


def extract_behavior(points: Iterable[TrackPoint], nearby_count: int = 0, group_size: int = 1) -> BehaviorFeatures:
    ordered = sorted(points, key=lambda point: point.timestamp)
    if not ordered:
        raise ValueError("At least one track point is required")
    distance = 0.0
    speeds = []
    for previous, current in zip(ordered, ordered[1:]):
        elapsed = current.timestamp - previous.timestamp
        step = hypot(current.x - previous.x, current.y - previous.y)
        distance += step
        if elapsed > 0:
            speeds.append(step / elapsed)
    elapsed_total = max(0.0, ordered[-1].timestamp - ordered[0].timestamp)
    dx = ordered[-1].x - ordered[0].x
    dy = ordered[-1].y - ordered[0].y
    direction = "stationary" if abs(dx) + abs(dy) < 1e-6 else ("east" if abs(dx) >= abs(dy) and dx > 0 else "west" if abs(dx) >= abs(dy) else "south" if dy > 0 else "north")
    zones = [point.zone for point in ordered if point.zone]
    transitions = sum(previous != current for previous, current in zip(zones, zones[1:]))
    hour = int(ordered[-1].timestamp // 3600) % 24
    time_of_day = "night" if hour >= 18 or hour < 6 else "day"
    return BehaviorFeatures(sum(speeds) / len(speeds) if speeds else 0.0, direction, elapsed_total, distance, transitions, time_of_day, nearby_count, group_size)
