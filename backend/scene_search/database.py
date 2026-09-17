from __future__ import annotations

import json
import sqlite3
from datetime import datetime
from pathlib import Path
from .models import Event, SearchHistoryItem, SearchResult


class EventRepository:
    def __init__(self, database_path: str | Path = "scene_search.db") -> None:
        self.database_path = str(database_path)
        self.connection = sqlite3.connect(self.database_path, check_same_thread=False, timeout=30.0, isolation_level=None)
        self.connection.row_factory = sqlite3.Row
        self.initialize()

    def initialize(self) -> None:
        self.connection.executescript("""
        CREATE TABLE IF NOT EXISTS cameras (camera_id TEXT PRIMARY KEY, camera_name TEXT, location TEXT, zone TEXT, latitude REAL, longitude REAL);
        CREATE TABLE IF NOT EXISTS zones (zone TEXT PRIMARY KEY);
        CREATE TABLE IF NOT EXISTS events (
          event_id TEXT PRIMARY KEY, camera_id TEXT NOT NULL, camera_name TEXT, location TEXT, zone TEXT,
          timestamp TEXT NOT NULL, frame_number INTEGER, track_id INTEGER, object_type TEXT NOT NULL,
          detection_confidence REAL NOT NULL, x1 REAL NOT NULL, y1 REAL NOT NULL, x2 REAL NOT NULL, y2 REAL NOT NULL,
          shirt_color TEXT, shirt_color_confidence REAL, vehicle_type TEXT, vehicle_color TEXT,
          plate_number TEXT, plate_confidence REAL, direction TEXT, speed REAL, dwell_time REAL,
          thumbnail_path TEXT, full_frame_path TEXT, clip_path TEXT, embedding TEXT
        );
        CREATE INDEX IF NOT EXISTS idx_events_time ON events(timestamp);
        CREATE INDEX IF NOT EXISTS idx_events_camera ON events(camera_id);
        CREATE INDEX IF NOT EXISTS idx_events_zone ON events(zone);
        CREATE INDEX IF NOT EXISTS idx_events_plate ON events(plate_number);
                CREATE TABLE IF NOT EXISTS search_history (
                    search_id INTEGER PRIMARY KEY AUTOINCREMENT,
                    query TEXT NOT NULL,
                    searched_at TEXT NOT NULL,
                    result_count INTEGER NOT NULL,
                    evidence TEXT NOT NULL DEFAULT '[]'
                );
        """)
        self.connection.commit()

    def save_search(self, query: str, results: list[SearchResult]) -> None:
        evidence = [result.model_dump(mode="json") for result in results[:6]]
        self.connection.execute(
            "INSERT INTO search_history (query, searched_at, result_count, evidence) VALUES (?, ?, ?, ?)",
            (query, datetime.now().astimezone().isoformat(), len(results), json.dumps(evidence)),
        )
        self.connection.commit()

    def search_history(self, limit: int = 20) -> list[SearchHistoryItem]:
        rows = self.connection.execute(
            "SELECT * FROM search_history ORDER BY search_id DESC LIMIT ?", (limit,)
        ).fetchall()
        return [SearchHistoryItem(
            search_id=row["search_id"],
            query=row["query"],
            searched_at=datetime.fromisoformat(row["searched_at"]),
            result_count=row["result_count"],
            evidence=[SearchResult.model_validate(item) for item in json.loads(row["evidence"])],
        ) for row in rows]

    def upsert(self, event: Event) -> None:
        values = event.model_dump()
        bbox = values.pop("bbox")
        values["timestamp"] = event.timestamp.isoformat()
        values.update({f"{key}": value for key, value in bbox.items()})
        values["embedding"] = json.dumps(values["embedding"]) if values["embedding"] is not None else None
        columns = list(values)
        placeholders = ",".join(f":{column}" for column in columns)
        self.connection.execute(f"INSERT OR REPLACE INTO events ({','.join(columns)}) VALUES ({placeholders})", values)
        self.connection.commit()

    def all(self) -> list[Event]:
        return self.search()

    def search(self, filters: dict[str, object] | None = None) -> list[Event]:
        clauses, params = [], {}
        filters = filters or {}
        for field, value in filters.items():
            if not value:
                continue
            if field == "camera_id":
                clauses.append("camera_id = :camera_id")
                params["camera_id"] = value
            elif field == "zone":
                clauses.append("LOWER(zone) LIKE LOWER(:zone)")
                params["zone"] = f"%{value}%"
            elif field == "vehicle_type":
                clauses.append("(vehicle_type = :vehicle_type OR object_type = :vehicle_type)")
                params["vehicle_type"] = value
            elif field == "object_type":
                if value == "vehicle":
                    clauses.append("(object_type IN ('vehicle', 'car', 'truck', 'bus', 'motorcycle', 'bicycle') OR vehicle_type IS NOT NULL)")
                else:
                    clauses.append("(object_type = :object_type OR vehicle_type = :object_type)")
                    params["object_type"] = value
            elif field in ("shirt_color", "vehicle_color", "plate_number"):
                clauses.append(f"{field} = :{field}")
                params[field] = value
        sql = "SELECT * FROM events" + (" WHERE " + " AND ".join(clauses) if clauses else "") + " ORDER BY timestamp DESC"
        return [self._event(row) for row in self.connection.execute(sql, params)]

    def get(self, event_id: str) -> Event | None:
        row = self.connection.execute("SELECT * FROM events WHERE event_id = ?", (event_id,)).fetchone()
        return self._event(row) if row else None

    @staticmethod
    def _event(row: sqlite3.Row) -> Event:
        data = dict(row)
        data["timestamp"] = datetime.fromisoformat(data["timestamp"])
        data["bbox"] = {key: data.pop(key) for key in ("x1", "y1", "x2", "y2")}
        data["embedding"] = json.loads(data["embedding"]) if data["embedding"] else None
        return Event.model_validate(data)
