from __future__ import annotations

from typing import Any

import numpy as np


def softmax(logits: np.ndarray, temperature: float = 1.0) -> np.ndarray:
    z = logits / max(float(temperature), 1e-6)
    z = z - np.max(z, axis=1, keepdims=True)
    exp = np.exp(z)
    return exp / np.sum(exp, axis=1, keepdims=True)


def expected_calibration_error(y_true: np.ndarray, probs: np.ndarray, n_bins: int = 15) -> float:
    confidences = np.max(probs, axis=1)
    predictions = np.argmax(probs, axis=1)
    accuracies = predictions == y_true
    ece = 0.0
    bin_boundaries = np.linspace(0.0, 1.0, n_bins + 1)
    for low, high in zip(bin_boundaries[:-1], bin_boundaries[1:]):
        mask = (confidences > low) & (confidences <= high)
        if not np.any(mask):
            continue
        ece += np.abs(np.mean(confidences[mask]) - np.mean(accuracies[mask])) * np.mean(mask)
    return float(ece)


def tune_temperature(y_true: np.ndarray, logits: np.ndarray) -> tuple[float, float, float]:
    before = expected_calibration_error(y_true, softmax(logits, 1.0))
    temps = np.linspace(0.7, 3.0, 47)
    best_temp = 1.0
    best_ece = before
    for t in temps:
        ece = expected_calibration_error(y_true, softmax(logits, float(t)))
        if ece < best_ece:
            best_ece = ece
            best_temp = float(t)
    return best_temp, before, best_ece


def reliability_bins(y_true: np.ndarray, probs: np.ndarray, n_bins: int = 15) -> list[dict[str, Any]]:
    conf = np.max(probs, axis=1)
    pred = np.argmax(probs, axis=1)
    acc = pred == y_true
    bins = []
    for i, (low, high) in enumerate(zip(np.linspace(0, 1, n_bins + 1)[:-1], np.linspace(0, 1, n_bins + 1)[1:])):
        mask = (conf > low) & (conf <= high)
        bins.append({
            "bin": i,
            "low": float(low),
            "high": float(high),
            "count": int(mask.sum()),
            "accuracy": float(np.mean(acc[mask])) if mask.any() else None,
            "confidence": float(np.mean(conf[mask])) if mask.any() else None,
        })
    return bins
