from __future__ import annotations

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[1]))

import argparse
import numpy as np
import tensorflow as tf

from src.data import build_tf_dataset, collect_split
from src.metrics import classification_report_dict, compute_metrics, confusion_matrix_dict, warnings_for_metrics
from src.utils import read_json, read_labels, write_json


def evaluate_split(model, data_dir, split, labels, meta, batch_size=32):
    x, y = collect_split(data_dir, split, labels)
    if not x:
        return None
    ds = build_tf_dataset(x, y, meta["inputSize"], batch_size, meta.get("normalization", {}).get("type", "scale_0_1"), training=False)
    probs = model.predict(ds, verbose=1)
    y_true = np.array(y)
    return {
        "metrics": compute_metrics(y_true, probs, labels),
        "classification_report": classification_report_dict(y_true, probs, labels),
        "confusion_matrix": confusion_matrix_dict(y_true, probs, labels),
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data_dir", default="dataset")
    parser.add_argument("--model_path", default="outputs/model.keras")
    parser.add_argument("--out_dir", default="outputs")
    parser.add_argument("--external_test_dir", default=None)
    args = parser.parse_args()
    labels = read_labels(f"{args.out_dir}/labels.txt")
    meta = read_json(f"{args.out_dir}/model_meta.json")
    model = tf.keras.models.load_model(args.model_path)
    test = evaluate_split(model, args.data_dir, "test", labels, meta)
    if test:
        test["metrics"]["warnings"] = warnings_for_metrics(test["metrics"])
        write_json(f"{args.out_dir}/metrics.json", test["metrics"])
        write_json(f"{args.out_dir}/classification_report.json", test["classification_report"])
        write_json(f"{args.out_dir}/confusion_matrix.json", test["confusion_matrix"])
    if args.external_test_dir:
        # External dir is treated as a dataset root containing label folders.
        external = evaluate_split(model, args.external_test_dir, ".", labels, meta)
        if external:
            external["metrics"]["warnings"] = warnings_for_metrics(external["metrics"])
            write_json(f"{args.out_dir}/external_metrics.json", external["metrics"])
            write_json(f"{args.out_dir}/external_classification_report.json", external["classification_report"])
            write_json(f"{args.out_dir}/external_confusion_matrix.json", external["confusion_matrix"])
    print("Evaluation completed.")


if __name__ == "__main__":
    main()
