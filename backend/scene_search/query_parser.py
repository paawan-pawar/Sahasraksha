from __future__ import annotations

import re
from datetime import datetime
from .models import ParsedQuery, SearchFilters

COLORS = {"red", "blue", "green", "yellow", "black", "white", "grey", "gray", "orange", "brown"}
VEHICLE_TYPES = {"car", "suv", "truck", "bus", "motorcycle", "bicycle", "van"}


class SceneQueryParser:
    def parse(self, query: str) -> ParsedQuery:
        text = query.strip()
        lower = text.lower()
        filters = SearchFilters()
        if re.search(r"\b(persons?|people|humans?|individuals?)\b", lower):
            filters.object_type = "person"
        elif re.search(r"\b(vehicle|vehicles|car|suv|truck|bus|motorcycle|bicycle|van)\b", lower):
            filters.object_type = "vehicle"
        colors = sorted(COLORS, key=len, reverse=True)
        color_match = re.search(r"\b(" + "|".join(colors) + r")\b", lower)
        if color_match:
            color = color_match.group(1).replace("gray", "grey")
            if filters.object_type == "person" or re.search(r"shirt|clothing|person|people|human", lower):
                filters.shirt_color = color
            else:
                filters.vehicle_color = color
        for vehicle_type in VEHICLE_TYPES:
            if re.search(rf"\b{re.escape(vehicle_type)}s?\b", lower):
                filters.vehicle_type = vehicle_type
                if filters.object_type is None:
                    filters.object_type = "vehicle"
                break
        plate_candidates = re.findall(r"\b[A-Z0-9-]{6,}\b", text, re.IGNORECASE)
        explicit_plate = re.search(r"(?:plate|number plate|registration)\s*(?:is|number)?\s*([A-Z0-9 -]{6,})", text, re.IGNORECASE)
        plate_value = explicit_plate.group(1) if explicit_plate else next((value for value in plate_candidates if any(char.isdigit() for char in value) and any(char.isalpha() for char in value)), None)
        if plate_value:
            filters.plate_number = self.normalize_plate(plate_value)
        camera = re.search(r"\b(?:camera|cam)[ -]?([A-Z0-9]+)\b", text, re.IGNORECASE)
        if camera:
            raw_cam = camera.group(1).upper()
            if raw_cam.isdigit():
                filters.camera_id = f"CAM{int(raw_cam):02d}"
            elif not raw_cam.startswith("CAM"):
                filters.camera_id = f"CAM{raw_cam}"
            else:
                filters.camera_id = raw_cam
        zone = re.search(r"\b(?:near|at|in|around)\s+(Gate\s+[A-Z0-9-]+|Sector\s+[A-Z0-9-]+|Zone\s+[A-Z0-9-]+)", text, re.IGNORECASE)
        if zone:
            filters.zone = zone.group(1).strip()
        time_range = re.search(r"\b(\d{1,2})(?::(\d{2}))?\s*(AM|PM)?\s*(?:-|to|and)\s*(\d{1,2})(?::(\d{2}))?\s*(AM|PM)?", text, re.IGNORECASE)
        if time_range:
            start = self.to_24_hour(time_range.group(1), time_range.group(2), time_range.group(3))
            end = self.to_24_hour(time_range.group(4), time_range.group(5), time_range.group(6))
            filters.start_time, filters.end_time = start, end
        if re.search(r"\b(night|nighttime|overnight)\b", lower):
            filters.time_period = "night"
        elif re.search(r"\b(day|daytime)\b", lower):
            filters.time_period = "day"
        known = {filters.object_type, filters.shirt_color, filters.vehicle_color, filters.vehicle_type, filters.plate_number, filters.camera_id, filters.zone, filters.time_period}
        filters.semantic_terms = [word for word in re.findall(r"[a-z0-9]+", lower) if word not in known and len(word) > 2]
        return ParsedQuery(filters=filters, original_query=query)

    @staticmethod
    def to_24_hour(hour: str, minute: str | None, meridiem: str | None) -> str:
        value = int(hour) % 24
        if meridiem and meridiem.lower() == "pm" and value < 12:
            value += 12
        if meridiem and meridiem.lower() == "am" and value == 12:
            value = 0
        return f"{value:02d}:{int(minute or 0):02d}"

    @staticmethod
    def normalize_plate(value: str) -> str:
        return re.sub(r"[^A-Z0-9]", "", value.upper())
