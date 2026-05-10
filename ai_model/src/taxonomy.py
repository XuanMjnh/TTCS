from __future__ import annotations

from pathlib import Path
from typing import Any

from .utils import read_json, validate_label_format, write_json


def load_taxonomy(path: str | Path | None) -> dict[str, Any]:
    if not path:
        return {}
    return read_json(path, default={}) or {}


def validate_taxonomy(labels: list[str], taxonomy: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    for label in labels:
        if not validate_label_format(label):
            errors.append(f"Invalid label format: {label}")
        if label not in taxonomy:
            errors.append(f"Missing taxonomy item for {label}")
            continue
        item = taxonomy[label]
        crop, condition = label.split("__", 1)
        if item.get("cropKey") != crop:
            errors.append(f"Taxonomy cropKey mismatch for {label}")
        if item.get("conditionKey") != condition:
            errors.append(f"Taxonomy conditionKey mismatch for {label}")
    return errors


def build_minimal_taxonomy(labels: list[str]) -> dict[str, Any]:
    result = {}
    for label in labels:
        crop, condition = label.split("__", 1)
        result[label] = {
            "label": label,
            "cropKey": crop,
            "cropNameVi": crop,
            "conditionKey": condition,
            "conditionNameVi": condition.replace("_", " "),
            "isDisease": condition != "healthy" and crop != "unknown",
            "isHealthy": condition == "healthy",
            "isUnknown": crop == "unknown",
            "articleLabel": label,
        }
    return result


def export_taxonomy(path: str | Path, labels: list[str], taxonomy: dict[str, Any] | None = None) -> dict[str, Any]:
    taxonomy = taxonomy or build_minimal_taxonomy(labels)
    filtered = {label: taxonomy.get(label) or build_minimal_taxonomy([label])[label] for label in labels}
    write_json(path, filtered)
    return filtered
