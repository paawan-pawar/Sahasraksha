from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import yaml

from .models import CameraConnection


@dataclass
class CameraGraph:
    connections: dict[str, list[CameraConnection]]

    @classmethod
    def from_config(cls, path: str | Path) -> "CameraGraph":
        raw = yaml.safe_load(Path(path).read_text(encoding="utf-8")) or {}
        connections: dict[str, list[CameraConnection]] = defaultdict(list)
        for source, edges in raw.get("connections", {}).items():
            for edge in edges:
                connections[source].append(CameraConnection(**edge))
        return cls(dict(connections))

    def next_connections(self, camera_id: str) -> list[CameraConnection]:
        return list(self.connections.get(camera_id, []))

    def has_connection(self, source: str, destination: str) -> bool:
        return any(edge.destination == destination for edge in self.next_connections(source))

    def to_dict(self) -> dict[str, Any]:
        return {
            source: [edge.__dict__ for edge in edges]
            for source, edges in self.connections.items()
        }
