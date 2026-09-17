from __future__ import annotations

from typing import Protocol


class AppearanceEncoder(Protocol):
    def encode(self, crop: object) -> list[float]: ...


class PersonReIDEncoder:
    """Replaceable OSNet/FastReID boundary; no pixel identity is inferred by this stub."""

    def encode(self, crop: object) -> list[float]:
        raise NotImplementedError("Install and wire an OSNet or FastReID encoder")


class VehicleReIDEncoder:
    """Vehicle embeddings, color/type features, and ANPR can be composed here."""

    def encode(self, crop: object) -> list[float]:
        raise NotImplementedError("Install and wire a vehicle Re-ID encoder")
