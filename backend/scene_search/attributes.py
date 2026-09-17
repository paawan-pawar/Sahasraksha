from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol


@dataclass(frozen=True)
class AttributePrediction:
    label: str
    confidence: float


class ClothingColorClassifier(Protocol):
    def predict(self, person_crop: object) -> AttributePrediction: ...


class HSVClothingColorClassifier:
    """CPU baseline for prototyping; replace with a trained crop classifier later."""

    def predict(self, person_crop: object) -> AttributePrediction:
        import cv2
        import numpy as np
        if person_crop is None or getattr(person_crop, "size", 0) == 0:
            return AttributePrediction("unknown", 0.0)
        height = person_crop.shape[0]
        upper = person_crop[: max(1, int(height * 0.55))]
        hsv = cv2.cvtColor(upper, cv2.COLOR_BGR2HSV)
        saturation = hsv[:, :, 1]
        value = hsv[:, :, 2]
        mean_hue = float(np.mean(hsv[:, :, 0]))
        mean_saturation = float(np.mean(saturation))
        mean_value = float(np.mean(value))
        if mean_value < 45:
            label = "black"
        elif mean_saturation < 35 and mean_value > 190:
            label = "white"
        elif mean_saturation < 40:
            label = "grey"
        elif mean_hue < 10 or mean_hue >= 170:
            label = "red"
        elif mean_hue < 25:
            label = "orange"
        elif mean_hue < 38:
            label = "yellow"
        elif mean_hue < 85:
            label = "green"
        elif mean_hue < 135:
            label = "blue"
        else:
            label = "purple"
        confidence = min(0.98, max(0.05, mean_saturation / 255 if label not in {"black", "white", "grey"} else 0.6))
        return AttributePrediction(label, confidence)


class TrainedColorClassifier:
    def __init__(self, weights_path: str) -> None:
        self.weights_path = weights_path

    def predict(self, person_crop: object) -> AttributePrediction:
        raise NotImplementedError("Load the exported custom classifier at this adapter boundary")
