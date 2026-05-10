from __future__ import annotations

from typing import Any

import numpy as np
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix, precision_recall_fscore_support


def top_k_accuracy(y_true: np.ndarray, probs: np.ndarray, k: int) -> float:
    if probs.size == 0:
        return 0.0
    k = min(k, probs.shape[1])
    topk = np.argsort(probs, axis=1)[:, -k:]
    return float(np.mean([y in topk[i] for i, y in enumerate(y_true)]))


def compute_metrics(y_true: list[int] | np.ndarray, probs: np.ndarray, labels: list[str]) -> dict[str, Any]:
    y_true = np.asarray(y_true)
    y_pred = np.argmax(probs, axis=1) if probs.size else np.array([], dtype=int)
    precision, recall, f1, support = precision_recall_fscore_support(y_true, y_pred, labels=np.arange(len(labels)), zero_division=0)
    macro = precision_recall_fscore_support(y_true, y_pred, average="macro", zero_division=0)
    weighted = precision_recall_fscore_support(y_true, y_pred, average="weighted", zero_division=0)
    per_class = {
        label: {"precision": float(precision[i]), "recall": float(recall[i]), "f1": float(f1[i]), "support": int(support[i])}
        for i, label in enumerate(labels)
    }
    return {
        "accuracy": float(accuracy_score(y_true, y_pred)) if len(y_true) else 0.0,
        "macroPrecision": float(macro[0]),
        "macroRecall": float(macro[1]),
        "macroF1": float(macro[2]),
        "weightedPrecision": float(weighted[0]),
        "weightedRecall": float(weighted[1]),
        "weightedF1": float(weighted[2]),
        "top2Accuracy": top_k_accuracy(y_true, probs, 2),
        "top3Accuracy": top_k_accuracy(y_true, probs, 3),
        "perClass": per_class,
    }


def classification_report_dict(y_true, probs, labels):
    y_pred = np.argmax(probs, axis=1)
    return classification_report(y_true, y_pred, labels=list(range(len(labels))), target_names=labels, output_dict=True, zero_division=0)


def confusion_matrix_dict(y_true, probs, labels):
    y_pred = np.argmax(probs, axis=1)
    cm = confusion_matrix(y_true, y_pred, labels=list(range(len(labels))))
    return {"labels": labels, "matrix": cm.tolist()}


def warnings_for_metrics(metrics: dict[str, Any]) -> list[str]:
    warnings: list[str] = []
    if metrics.get("macroF1", 0.0) < 0.80:
        warnings.append("macro_f1_below_0_80")
    for label, values in metrics.get("perClass", {}).items():
        if label.endswith("__healthy") and values.get("recall", 0.0) < 0.85:
            warnings.append(f"healthy_recall_low:{label}")
        elif label.startswith("unknown__") and values.get("recall", 0.0) < 0.80:
            warnings.append(f"unknown_recall_low:{label}")
        elif not label.endswith("__healthy") and not label.startswith("unknown__"):
            if values.get("recall", 0.0) < 0.75:
                warnings.append(f"disease_recall_low:{label}")
            if values.get("precision", 0.0) < 0.75:
                warnings.append(f"disease_precision_low:{label}")
    return warnings
