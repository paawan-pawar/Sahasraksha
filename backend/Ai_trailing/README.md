# AI Trailing backend

## Run

```powershell
cd backend\Ai_trailing
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
$env:PYTHONPATH = (Get-Location).Path
uvicorn app.main:app --reload --port 8000
```

The API starts with no fabricated entities. Configure recorded files and a model pipeline before observations are emitted. YOLO11x downloads on first `Yolo11Detector.load()` through Ultralytics; ByteTrack is camera-local. Re-ID encoders are explicit replaceable adapters and must be installed/wired for cross-camera identity.

Endpoints: `/health`, `/entities`, `/entities/{global_id}`, `/entities/{global_id}/trajectory`, `/entities/{global_id}/history`, `/entities/{global_id}/prediction`, `/cameras`, `/cameras/{camera_id}/connections`, and `/ws/tracking`.

Run core tests from `backend\Ai_trailing`: `python -m pytest`.
