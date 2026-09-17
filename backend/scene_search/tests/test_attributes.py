from scene_search.ocr import OCRPrediction, ObservationAggregator, PlateNormalizer
from scene_search.scene import TrackPoint, extract_behavior


def test_plate_observations_are_normalized_and_aggregated():
    aggregator = ObservationAggregator()
    assert aggregator.add("C01:4", OCRPrediction("mp09-ab 1234", .8)).plate_number == "MP09AB1234"
    assert aggregator.add("C01:4", OCRPrediction("MP09AB1234", .9)).confidence == .9
    assert PlateNormalizer.normalize("mp09-ab 1234") == "MP09AB1234"


def test_behavior_features_capture_motion_and_zone_transition():
    result = extract_behavior([TrackPoint(0, 0, 0, "Gate 1"), TrackPoint(5, 10, 0, "Gate 1"), TrackPoint(10, 20, 0, "Gate 3")])
    assert result.direction == "east"
    assert result.zone_transitions == 1
    assert result.trajectory_length == 20
