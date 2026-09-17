CREATE TABLE entities (
  global_id TEXT PRIMARY KEY,
  entity_type TEXT NOT NULL,
  first_seen TIMESTAMPTZ NOT NULL,
  last_seen TIMESTAMPTZ NOT NULL,
  current_camera TEXT NOT NULL,
  confidence REAL NOT NULL,
  appearance_embedding JSONB
);
CREATE TABLE observations (
  id BIGSERIAL PRIMARY KEY,
  global_id TEXT REFERENCES entities(global_id),
  camera_id TEXT NOT NULL,
  local_track_id INTEGER NOT NULL,
  observed_at TIMESTAMPTZ NOT NULL,
  bbox JSONB NOT NULL,
  center_position JSONB NOT NULL,
  confidence REAL NOT NULL,
  coordinate_space TEXT NOT NULL,
  evidence_uri TEXT
);
CREATE TABLE camera_graph (
  source_camera TEXT NOT NULL,
  destination_camera TEXT NOT NULL,
  distance_m REAL,
  direction TEXT,
  min_travel_seconds REAL NOT NULL,
  max_travel_seconds REAL NOT NULL,
  restricted BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (source_camera, destination_camera)
);
CREATE TABLE predictions (
  id BIGSERIAL PRIMARY KEY,
  global_id TEXT REFERENCES entities(global_id),
  predicted_camera TEXT NOT NULL,
  probability REAL NOT NULL,
  expected_time_seconds REAL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
