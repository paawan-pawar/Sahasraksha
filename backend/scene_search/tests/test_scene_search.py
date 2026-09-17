from datetime import datetime

from scene_search.database import EventRepository
from scene_search.models import BoundingBox, Event
from scene_search.query_parser import SceneQueryParser
from scene_search.search import HybridSearchEngine


def make_event(event_id: str, hour: int, color: str = "red") -> Event:
    return Event(event_id=event_id, camera_id="C03", zone="Gate 3", timestamp=datetime(2026, 9, 17, hour, 28), object_type="person", detection_confidence=.97, bbox=BoundingBox(x1=1, y1=2, x2=3, y2=4), shirt_color=color, shirt_color_confidence=.9, embedding=[1, 0])


def test_parser_extracts_structured_scene_query():
    parsed = SceneQueryParser().parse("Find all red-shirt persons near Gate 3 between 2 PM and 3 PM")
    assert parsed.filters.object_type == "person"
    assert parsed.filters.shirt_color == "red"
    assert parsed.filters.zone == "Gate 3"
    assert parsed.filters.start_time == "14:00"
    assert parsed.filters.end_time == "15:00"


def test_hybrid_search_applies_metadata_and_time_filters(tmp_path):
    repository = EventRepository(tmp_path / "events.db")
    engine = HybridSearchEngine(repository)
    engine.index(make_event("match", 14))
    engine.index(make_event("wrong-color", 14, "blue"))
    engine.index(make_event("wrong-time", 16))
    parsed = SceneQueryParser().parse("Find red-shirt persons near Gate 3 between 2 PM and 3 PM")
    results, total = engine.search(parsed)
    assert total == 1
    assert [result.event_id for result in results] == ["match"]


def test_plate_normalization():
    assert SceneQueryParser.normalize_plate("mp09-ab 1234") == "MP09AB1234"
