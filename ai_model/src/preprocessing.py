from __future__ import annotations

from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageOps


def load_image_rgb(path: str | Path) -> Image.Image:
    image = Image.open(path)
    image = ImageOps.exif_transpose(image)
    return image.convert("RGB")


def resize_to_square(image: Image.Image, size: int) -> Image.Image:
    return image.resize((size, size), Image.Resampling.BILINEAR)


def normalize_array(arr: np.ndarray, normalization: dict[str, Any] | str = "scale_0_1") -> np.ndarray:
    if isinstance(normalization, str):
        norm_type = normalization
        scale = 255.0
        mean = [0.0, 0.0, 0.0]
        std = [1.0, 1.0, 1.0]
    else:
        norm_type = normalization.get("type", "scale_0_1")
        scale = float(normalization.get("scale", 255.0))
        mean = normalization.get("mean", [0.0, 0.0, 0.0])
        std = normalization.get("std", [1.0, 1.0, 1.0])
    arr = arr.astype("float32")
    if norm_type == "scale_0_1":
        arr = arr / scale
    elif norm_type == "minus1_1":
        arr = (arr / 127.5) - 1.0
    elif norm_type == "standardize":
        arr = (arr / scale - np.array(mean, dtype=np.float32)) / np.array(std, dtype=np.float32)
    elif norm_type == "none":
        pass
    else:
        raise ValueError(f"Unsupported normalization type: {norm_type}")
    return arr


def preprocess_path(path: str | Path, input_size: int, normalization: dict[str, Any] | str = "scale_0_1") -> np.ndarray:
    img = load_image_rgb(path)
    img = resize_to_square(img, input_size)
    arr = np.asarray(img, dtype=np.float32)
    return normalize_array(arr, normalization)


def preprocess_batch(paths: list[str | Path], input_size: int, normalization: dict[str, Any] | str = "scale_0_1") -> np.ndarray:
    return np.stack([preprocess_path(p, input_size, normalization) for p in paths], axis=0)
