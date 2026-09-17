# IBVAP backend

This folder is self-contained and can be moved to a private repository. It contains the AI Trailing and Scene Search services, backend-local configuration, tests, and environment templates. The Flutter app is a separate client and communicates only through HTTP/WebSocket APIs.

## Setup

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r Ai_trailing\requirements.txt
pip install -r scene_search\requirements.txt
Copy-Item .env.example .env
```

The current prototype keeps the two services independently deployable:

```powershell
$env:PYTHONPATH = (Get-Location).Path
uvicorn Ai_trailing.app.main:app --reload --host 127.0.0.1 --port 8000
uvicorn scene_search.main:app --reload --host 127.0.0.1 --port 8001
```

Alternatively, run each service from its own directory using the commands in its README. Environment variables control hosts, ports, CORS origins, camera config, and the Scene Search database path. Copy `.env.example` to `.env`; `.env` is ignored by Git.

## Private repository boundary

Commit this entire `backend/` folder to the private backend repository. Do not commit `.venv/`, `.env`, generated SQLite files, model weights, media outputs, or secrets. The `../assets` paths in the sample configs are for this monorepo; in a standalone backend repository set `AI_TRAILING_CONFIG` to a private config path and point camera sources to mounted media or object storage.

## API contracts

AI Trailing: `/health`, `/entities`, `/entities/{global_id}`, `/entities/{global_id}/trajectory`, `/entities/{global_id}/history`, `/entities/{global_id}/prediction`, `/cameras`, `/cameras/{camera_id}/connections`, `/ws/tracking`.

Scene Search: `/health`, `/events`, `/process/video`, `/search`, `/events/{event_id}`, `/events/{event_id}/clip`, `/cameras`, `/zones`, `/statistics`.

Run tests from this folder:

```powershell
$env:PYTHONPATH = (Get-Location).Path
python -m pytest Ai_trailing\tests scene_search\tests -q
```
