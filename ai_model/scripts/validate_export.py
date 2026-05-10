from __future__ import annotations

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[1]))

import argparse
from pathlib import Path

from src.taxonomy import validate_taxonomy
from src.utils import mark_not_ready, read_json, read_labels, write_json


def in_range(x):
    return isinstance(x, (int, float)) and 0.0 <= float(x) <= 1.0


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--export_dir", default="outputs")
    parser.add_argument("--taxonomy_file", required=True)
    parser.add_argument("--advice_file", required=True)
    args = parser.parse_args()
    export = Path(args.export_dir)
    errors = []
    warnings = []
    required = ["model.tflite", "labels.txt", "model_meta.json"]
    for name in required:
        if not (export / name).exists():
            errors.append(f"Missing {name}")
    labels = read_labels(export / "labels.txt") if (export / "labels.txt").exists() else []
    meta = read_json(export / "model_meta.json", {}) or {}
    taxonomy = read_json(args.taxonomy_file, {}) or {}
    advice = read_json(args.advice_file, {}) or {}
    if meta.get("numClasses") != len(labels):
        errors.append("model_meta.numClasses does not equal labels.txt line count")
    if meta.get("topK", 0) > len(labels):
        errors.append("topK is larger than number of classes")
    errors.extend(validate_taxonomy(labels, taxonomy))
    for label in labels:
        item = taxonomy.get(label, {})
        if (item.get("isDisease") or item.get("isHealthy") or item.get("isUnknown")) and label not in advice:
            errors.append(f"Missing advice for {label}")
    th = meta.get("thresholding", {})
    if th.get("method") != "validation_tuned":
        errors.append("Thresholds are not tuned from validation set")
    if not in_range(th.get("globalConfidenceThreshold")):
        errors.append("Invalid global confidence threshold")
    if not in_range(th.get("globalUncertaintyMargin")):
        errors.append("Invalid global uncertainty margin")
    norm = meta.get("normalization", {})
    if norm.get("type") not in {"scale_0_1", "minus1_1", "standardize", "none"}:
        errors.append("Unsupported preprocessing normalization")

    metrics = read_json(export / "metrics.json", {}) or {}
    if metrics:
        if metrics.get("macroF1", 0) < 0.80:
            errors.append("macro F1 < 0.80")
        if metrics.get("weightedF1", 0) < 0.85:
            errors.append("weighted F1 < 0.85")
        for label, v in metrics.get("perClass", {}).items():
            if label.endswith("__healthy") and v.get("recall", 0) < 0.85:
                errors.append(f"healthy recall < 0.85: {label}")
            elif label.startswith("unknown__") and v.get("recall", 0) < 0.80:
                errors.append(f"unknown recall < 0.80: {label}")
            elif not label.endswith("__healthy") and not label.startswith("unknown__"):
                if v.get("recall", 0) < 0.75:
                    errors.append(f"disease recall < 0.75: {label}")
                if v.get("precision", 0) < 0.75:
                    errors.append(f"disease precision < 0.75: {label}")
    parity = read_json(export / "tflite_parity_report.json", {}) or {}
    if parity and parity.get("top1MatchRate", 0) < 0.99:
        errors.append("Keras/TFLite top1 match rate < 0.99")

    ready = not errors
    meta.setdefault("acceptance", {})["readyForProduction"] = ready
    meta["acceptance"]["status"] = "READY_FOR_PRODUCTION" if ready else "MODEL_NOT_READY_FOR_PRODUCTION"
    meta["acceptance"]["reasons"] = [] if ready else errors
    write_json(export / "model_meta.json", meta)
    if metrics:
        metrics["acceptanceStatus"] = meta["acceptance"]["status"]
        write_json(export / "metrics.json", metrics)
    report = {"readyForProduction": ready, "status": meta["acceptance"]["status"], "errors": errors, "warnings": warnings}
    write_json(export / "validate_export_report.json", report)
    print(report)


if __name__ == "__main__":
    main()
