from __future__ import annotations

import os
from pathlib import Path

from dotenv import load_dotenv

BACKEND_ROOT = Path(__file__).resolve().parents[1]
load_dotenv(BACKEND_ROOT / ".env")


def path_from_env(name: str, default: str) -> Path:
    value = Path(os.getenv(name, default))
    return value if value.is_absolute() else BACKEND_ROOT / value


def cors_origins(name: str, default: str) -> list[str]:
    return [origin.strip() for origin in os.getenv(name, default).split(",") if origin.strip()]
