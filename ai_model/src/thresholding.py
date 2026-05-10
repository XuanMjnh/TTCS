from __future__ import annotations

from typing import Any

import numpy as np


def tune_thresholds_from_validation(y_true: np.ndarray, probs: np.ndarray, labels: list[str]) -> dict[str, Any]:
    if len(y_true) == 0:
        raise ValueError("Validation set is empty; cannot tune thresholds.")
    pred = np.argmax(probs, axis=1)
    sorted_probs = np.sort(probs, axis=1)
    conf = sorted_probs[:, -1]
    margin = sorted_probs[:, -1] - sorted_probs[:, -2] if probs.shape[1] > 1 else sorted_probs[:, -1]

    candidates = np.linspace(0.50, 0.95, 46)
    margin_candidates = np.linspace(0.05, 0.30, 26)
    best_score = -1.0
    best_global = 0.78
    best_margin = 0.15
    for t in candidates:
        for m in margin_candidates:
            accepted = (conf >= t) & (margin >= m)
            if accepted.sum() == 0:
                continue
            acc = np.mean(pred[accepted] == y_true[accepted])
            coverage = accepted.mean()
            score = (0.75 * acc) + (0.25 * coverage) - max(0.0, 0.90 - acc)
            if score > best_score:
                best_score = float(score)
                best_global = float(t)
                best_margin = float(m)

    per_class: dict[str, float] = {}
    for i, label in enumerate(labels):
        idx = pred == i
        if idx.sum() < 5:
            per_class[label] = best_global
            continue
        class_conf = conf[idx]
        class_correct = (pred[idx] == y_true[idx])
        best_t = best_global
        for t in candidates:
            accepted = class_conf >= t
            if accepted.sum() < 3:
                continue
            precision_proxy = np.mean(class_correct[accepted])
            if precision_proxy >= 0.90:
                best_t = float(t)
                break
        if label.startswith("unknown__"):
            best_t = min(best_t, 0.75)
        if label.endswith("__healthy"):
            best_t = max(best_t, 0.80)
        per_class[label] = round(float(best_t), 4)

    return {
        "method": "validation_tuned",
        "globalConfidenceThreshold": round(best_global, 4),
        "globalUncertaintyMargin": round(best_margin, 4),
        "perClassThresholdsEnabled": True,
        "perClassThresholds": per_class,
    }


def apply_threshold_to_meta(meta: dict[str, Any], thresholds: dict[str, Any]) -> dict[str, Any]:
    meta["thresholding"] = thresholds
    return meta
