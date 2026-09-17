# Scene Search backend

This module indexes structured visual events once and searches the index later. It does not fabricate detections or claim semantic matches without indexed event data.

## Run

```powershell
cd backend\scene_search
..\..\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
$env:PYTHONPATH = (Get-Location).Path
uvicorn main:app --reload --port 8001
```

Endpoints: `GET /health`, `POST /events`, `POST /process/cameras`, `POST /search`, `GET /search/history`, `GET /events/{event_id}`, `GET /events/{event_id}/clip`, `GET /cameras`, `GET /zones`, and `GET /statistics`.

Example index request:

```json
{"event_id":"evt-1","camera_id":"C03","zone":"Gate 3","timestamp":"2026-09-17T14:28:17","object_type":"person","detection_confidence":0.97,"bbox":{"x1":10,"y1":20,"x2":80,"y2":180},"shirt_color":"red","shirt_color_confidence":0.91,"thumbnail_path":"media/evt-1.jpg","clip_path":"media/evt-1.mp4"}
```

Example search request:

```json
{"query":"Find red-shirt persons near Gate 3 between 2 PM and 3 PM"}
```

SQLite is used for event metadata. `VectorIndex` uses cosine similarity and automatically uses FAISS when `faiss-cpu` is installed. `video.py` provides an OpenCV frame-sampling loop with injected extraction. `attributes.py` includes a low-confidence HSV shirt-color baseline and a trained-classifier adapter. `ocr.py` normalizes and aggregates repeated plate observations while rejecting poor reads. `scene.py` calculates speed, direction, dwell time, trajectory length, zone transitions, day/night, nearby count, and group size. These are prototype components, not measured production accuracy.

Tests: `python -m pytest tests -q`.
