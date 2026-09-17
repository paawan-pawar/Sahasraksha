from __future__ import annotations

from collections import Counter, defaultdict
from datetime import datetime
from typing import Protocol

from .camera_graph import CameraGraph
from .models import GlobalEntity, Prediction


class Predictor(Protocol):
    def predict(self, entity: GlobalEntity) -> list[Prediction]: ...


class MarkovCameraPredictor:
    def __init__(self, graph: CameraGraph) -> None:
        self.graph = graph
        self.transitions: dict[str, Counter[str]] = defaultdict(Counter)

    def learn(self, entities: list[GlobalEntity]) -> None:
        self.transitions.clear()
        for entity in entities:
            sequence = []
            for observation in sorted(entity.observations, key=lambda item: item.timestamp):
                if not sequence or sequence[-1] != observation.camera_id:
                    sequence.append(observation.camera_id)
            for source, destination in zip(sequence, sequence[1:]):
                self.transitions[source][destination] += 1

    def predict(self, entity: GlobalEntity) -> list[Prediction]:
        source = entity.current_camera
        counts = self.transitions.get(source, Counter())
        edges = {edge.destination: edge for edge in self.graph.next_connections(source)}
        candidates = [(destination, count) for destination, count in counts.items() if destination in edges]
        if not candidates:
            candidates = [(edge.destination, 1) for edge in self.graph.next_connections(source) if not edge.restricted]
        total = sum(count for _, count in candidates)
        if not total:
            return []
        predictions = []
        for destination, count in sorted(candidates, key=lambda item: item[1], reverse=True):
            edge = edges[destination]
            predictions.append(Prediction(
                predicted_camera=destination,
                predicted_zone=edge.destination_zone,
                probability=count / total,
                expected_time_seconds=(edge.min_travel_seconds + edge.max_travel_seconds) / 2,
            ))
        return predictions
