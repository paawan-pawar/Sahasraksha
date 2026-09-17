from __future__ import annotations

from math import sqrt
from typing import Iterable

from .models import Event


class VectorIndex:
    """Small local vector index with optional FAISS acceleration."""

    def __init__(self) -> None:
        self._vectors: dict[str, list[float]] = {}
        self._faiss = None
        self._index = None
        try:
            import faiss  # type: ignore
            self._faiss = faiss
        except ImportError:
            pass

    def add(self, event: Event) -> None:
        if event.embedding:
            self._vectors[event.event_id] = self.normalize(event.embedding)
            self._rebuild()

    def add_many(self, events: Iterable[Event]) -> None:
        for event in events:
            if event.embedding:
                self._vectors[event.event_id] = self.normalize(event.embedding)
        self._rebuild()

    def search(self, query: list[float], top_k: int = 50, threshold: float = 0.0) -> list[tuple[str, float]]:
        if not query or not self._vectors:
            return []
        query = self.normalize(query)
        if self._index is not None:
            import numpy as np
            scores, indexes = self._index.search(np.asarray([query], dtype="float32"), top_k)
            ids = list(self._vectors)
            return [(ids[index], float(score)) for index, score in zip(indexes[0], scores[0]) if index >= 0 and score >= threshold]
        scored = [(event_id, sum(a * b for a, b in zip(vector, query))) for event_id, vector in self._vectors.items()]
        return [(event_id, score) for event_id, score in sorted(scored, key=lambda item: item[1], reverse=True)[:top_k] if score >= threshold]

    def _rebuild(self) -> None:
        if self._faiss is None or not self._vectors:
            return
        import numpy as np
        matrix = np.asarray(list(self._vectors.values()), dtype="float32")
        self._index = self._faiss.IndexFlatIP(matrix.shape[1])
        self._index.add(matrix)

    @staticmethod
    def normalize(vector: list[float]) -> list[float]:
        magnitude = sqrt(sum(value * value for value in vector))
        return [value / magnitude for value in vector] if magnitude else vector
