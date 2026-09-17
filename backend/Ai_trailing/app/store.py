from __future__ import annotations

from threading import Lock
from .core.models import GlobalEntity, Observation


class TrackingStore:
    def __init__(self) -> None:
        self._entities: dict[str, GlobalEntity] = {}
        self._lock = Lock()

    def upsert(self, entity: GlobalEntity) -> None:
        with self._lock:
            self._entities[entity.global_id] = entity

    def add_observation(self, global_id: str, observation: Observation) -> GlobalEntity:
        with self._lock:
            entity = self._entities[global_id]
            entity.add_observation(observation)
            return entity

    def all(self) -> list[GlobalEntity]:
        with self._lock:
            return list(self._entities.values())

    def get(self, global_id: str) -> GlobalEntity | None:
        with self._lock:
            return self._entities.get(global_id)
