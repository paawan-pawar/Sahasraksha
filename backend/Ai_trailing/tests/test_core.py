from datetime import datetime, timedelta, timezone

from app.core.camera_graph import CameraGraph
from app.core.matcher import CrossCameraMatcher
from app.core.models import BoundingBox, GlobalEntity, Observation
from app.core.predictor import MarkovCameraPredictor
from app.core.trajectory import TrajectoryManager


def observation(camera: str, seconds: int, track: int = 1, embedding: list[float] | None = None) -> Observation:
    return Observation(camera, track, "person", datetime(2026, 1, 1, tzinfo=timezone.utc) + timedelta(seconds=seconds), BoundingBox(0, 0, 10, 20), 0.9, embedding or [1.0, 0.0], (float(seconds), 0.0), "ground")


def graph() -> CameraGraph:
    return CameraGraph({"CAM01": [type("Edge", (), {"destination": "CAM02", "destination_zone": "lane", "min_travel_seconds": 1, "max_travel_seconds": 30, "restricted": False})()], "CAM02": [type("Edge", (), {"destination": "CAM04", "destination_zone": "road", "min_travel_seconds": 1, "max_travel_seconds": 30, "restricted": False})()]})


def test_trajectory_reconstructs_sequence_and_metrics():
    entity = GlobalEntity("ENTITY_1", "person", observation("CAM01", 0).timestamp, observation("CAM02", 5).timestamp, "CAM01", (0, 0), 0.8, [observation("CAM01", 0), observation("CAM01", 2), observation("CAM02", 5)])
    result = TrajectoryManager().response(entity)
    assert result["camera_sequence"] == ["CAM01", "CAM02"]
    assert result["transitions"][0]["travel_seconds"] == 3


def test_cross_camera_match_requires_multiple_signals():
    result = CrossCameraMatcher(graph()).score(observation("CAM01", 0), observation("CAM02", 5))
    assert result.matched
    assert result.evidence["appearance_similarity"] == 1.0


def test_markov_prediction_returns_probabilities():
    entities = [GlobalEntity(str(index), "person", observation("CAM01", 0).timestamp, observation(destination, 5).timestamp, destination, (0, 0), 0.8, [observation("CAM01", 0), observation(destination, 5)]) for index, destination in enumerate(["CAM02", "CAM02", "CAM02"])]
    predictor = MarkovCameraPredictor(graph())
    predictor.learn(entities)
    target = entities[0]
    target.current_camera = "CAM01"
    predictions = predictor.predict(target)
    assert predictions[0].predicted_camera == "CAM02"
    assert sum(item.probability for item in predictions) == 1


def test_confidence_is_bounded():
    result = CrossCameraMatcher(graph()).score(observation("CAM01", 0), observation("CAM02", 5))
    assert 0 <= result.confidence <= 1
