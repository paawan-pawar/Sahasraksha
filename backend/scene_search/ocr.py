from __future__ import annotations

import re
from collections import Counter
from dataclasses import dataclass
from typing import Protocol


@dataclass(frozen=True)
class OCRPrediction:
    plate_number: str
    confidence: float


class PlateOCR(Protocol):
    def read(self, plate_crop: object) -> OCRPrediction: ...


class PlateNormalizer:
    @staticmethod
    def normalize(value: str) -> str:
        return re.sub(r"[^A-Z0-9]", "", value.upper())

    @staticmethod
    def acceptable(prediction: OCRPrediction, minimum_confidence: float = 0.55) -> bool:
        normalized = PlateNormalizer.normalize(prediction.plate_number)
        return minimum_confidence <= prediction.confidence <= 1 and 4 <= len(normalized) <= 12 and any(char.isalpha() for char in normalized) and any(char.isdigit() for char in normalized)


class ObservationAggregator:
    def __init__(self, minimum_confidence: float = 0.55) -> None:
        self.minimum_confidence = minimum_confidence
        self._observations: dict[str, list[OCRPrediction]] = {}

    def add(self, track_key: str, prediction: OCRPrediction) -> OCRPrediction | None:
        if not PlateNormalizer.acceptable(prediction, self.minimum_confidence):
            return None
        normalized = OCRPrediction(PlateNormalizer.normalize(prediction.plate_number), prediction.confidence)
        self._observations.setdefault(track_key, []).append(normalized)
        return self.best(track_key)

    def best(self, track_key: str) -> OCRPrediction | None:
        observations = self._observations.get(track_key, [])
        if not observations:
            return None
        counts = Counter(item.plate_number for item in observations)
        plate = counts.most_common(1)[0][0]
        confidence = max(item.confidence for item in observations if item.plate_number == plate)
        return OCRPrediction(plate, confidence)
