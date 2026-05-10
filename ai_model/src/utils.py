from __future__ import annotations

import json
import os
import random
from pathlib import Path
from typing import Any, Iterable

import numpy as np

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}


def set_global_seed(seed: int) -> None:
    random.seed(seed)
    np.random.seed(seed)
    os.environ["PYTHONHASHSEED"] = str(seed)
    try:
        import tensorflow as tf
        tf.keras.utils.set_random_seed(seed)
    except Exception:
        pass


def ensure_dir(path: str | Path) -> Path:
    p = Path(path)
    p.mkdir(parents=True, exist_ok=True)
    return p


def read_json(path: str | Path, default: Any = None) -> Any:
    p = Path(path)
    if not p.exists():
        return default
    return json.loads(p.read_text(encoding="utf-8"))


def write_json(path: str | Path, data: Any) -> None:
    p = Path(path)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(data, ensure_ascii=False, indent=2, default=_json_default), encoding="utf-8")


def _json_default(value: Any) -> Any:
    if isinstance(value, np.generic):
        return value.item()
    if isinstance(value, np.ndarray):
        return value.tolist()
    if isinstance(value, Path):
        return str(value)
    raise TypeError(f"Object of type {value.__class__.__name__} is not JSON serializable")


def read_labels(path: str | Path) -> list[str]:
    return [line.strip() for line in Path(path).read_text(encoding="utf-8").splitlines() if line.strip()]


def write_labels(path: str | Path, labels: Iterable[str]) -> None:
    p = Path(path)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text("\n".join(labels) + "\n", encoding="utf-8")


def list_image_files(folder: str | Path) -> list[Path]:
    p = Path(folder)
    if not p.exists():
        return []
    return sorted(x for x in p.rglob("*") if x.suffix.lower() in IMAGE_EXTENSIONS)


def validate_label_format(label: str) -> bool:
    if "__" not in label or label.count("__") != 1:
        return False
    allowed = set("abcdefghijklmnopqrstuvwxyz0123456789_")
    return label == label.lower() and all(ch in allowed for ch in label.replace("__", "_"))


def mark_not_ready(meta: dict[str, Any], reason: str) -> dict[str, Any]:
    meta.setdefault("acceptance", {})["readyForProduction"] = False
    meta["acceptance"]["status"] = "MODEL_NOT_READY_FOR_PRODUCTION"
    meta["acceptance"].setdefault("reasons", [])
    if reason not in meta["acceptance"]["reasons"]:
        meta["acceptance"]["reasons"].append(reason)
    return meta
