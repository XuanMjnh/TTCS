from __future__ import annotations

from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any

import cv2
import imagehash
import numpy as np
from PIL import Image, ImageOps

from .utils import IMAGE_EXTENSIONS, list_image_files, write_json


@dataclass
class ImageQuality:
    path: str
    ok: bool
    width: int | None = None
    height: int | None = None
    brightness: float | None = None
    sharpness: float | None = None
    channels: int | None = None
    reasons: list[str] | None = None

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


def compute_brightness_and_sharpness(image_rgb: np.ndarray) -> tuple[float, float]:
    gray = cv2.cvtColor(image_rgb, cv2.COLOR_RGB2GRAY)
    brightness = float(np.mean(gray))
    sharpness = float(cv2.Laplacian(gray, cv2.CV_64F).var())
    return brightness, sharpness


def check_image_quality(path: str | Path, min_size: int = 96, min_brightness: float = 35.0, max_brightness: float = 230.0, min_sharpness: float = 80.0) -> ImageQuality:
    reasons: list[str] = []
    try:
        img = Image.open(path)
        img.verify()
        img = ImageOps.exif_transpose(Image.open(path))
        width, height = img.size
        if width < min_size or height < min_size:
            reasons.append("too_small")
        arr = np.asarray(img.convert("RGB"))
        brightness, sharpness = compute_brightness_and_sharpness(arr)
        if brightness < min_brightness:
            reasons.append("too_dark")
        if brightness > max_brightness:
            reasons.append("too_bright")
        if sharpness < min_sharpness:
            reasons.append("too_blurry")
        channels = 1 if len(np.asarray(img).shape) == 2 else np.asarray(img).shape[-1]
        if channels not in (3, 4):
            reasons.append("invalid_channels")
        return ImageQuality(str(path), not reasons, width, height, brightness, sharpness, channels, reasons)
    except Exception as exc:
        return ImageQuality(str(path), False, reasons=[f"corrupt_or_unreadable:{exc}"])


def find_near_duplicates(data_dir: str | Path, max_distance: int = 3) -> list[dict[str, Any]]:
    files = list_image_files(data_dir)
    hashes: list[tuple[Path, imagehash.ImageHash]] = []
    duplicates: list[dict[str, Any]] = []
    for path in files:
        try:
            h = imagehash.phash(Image.open(path))
            for other_path, other_hash in hashes:
                dist = h - other_hash
                if dist <= max_distance:
                    duplicates.append({"path": str(path), "nearDuplicateOf": str(other_path), "distance": int(dist)})
            hashes.append((path, h))
        except Exception:
            continue
    return duplicates


def dataset_quality_report(data_dir: str | Path, out_dir: str | Path) -> dict[str, Any]:
    files = list_image_files(data_dir)
    checks = [check_image_quality(path).to_dict() for path in files]
    class_counts: dict[str, int] = {}
    for path in files:
        label = path.parent.name
        if "__" in label:
            class_counts[label] = class_counts.get(label, 0) + 1
    duplicates = find_near_duplicates(data_dir)
    report = {
        "numImages": len(files),
        "numIssues": sum(0 if c["ok"] else 1 for c in checks),
        "classCounts": dict(sorted(class_counts.items())),
        "lowCountClasses": {k: v for k, v in class_counts.items() if v < 20},
        "qualityChecks": checks,
        "nearDuplicates": duplicates,
    }
    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    write_json(out / "dataset_quality_report.json", report)
    lines = ["# Dataset quality report", "", f"Images: {len(files)}", f"Issues: {report['numIssues']}", "", "## Low count classes"]
    for k, v in report["lowCountClasses"].items():
        lines.append(f"- {k}: {v}")
    lines += ["", "## Problem images"]
    for c in checks:
        if not c["ok"]:
            lines.append(f"- `{c['path']}`: {', '.join(c.get('reasons') or [])}")
    (out / "dataset_quality_report.md").write_text("\n".join(lines), encoding="utf-8")
    return report
