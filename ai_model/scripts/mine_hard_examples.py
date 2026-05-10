from __future__ import annotations

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[1]))

import argparse
import shutil
from pathlib import Path

import numpy as np
import tensorflow as tf

from src.data import build_tf_dataset, collect_split
from src.utils import ensure_dir, read_json, read_labels, write_json


def mine_split(model, data_dir, split, labels, meta, out_dir, min_conf=0.85):
    paths, y = collect_split(data_dir, split, labels)
    if not paths:
        return []
    ds = build_tf_dataset(paths, y, meta["inputSize"], 32, meta.get("normalization", {}).get("type", "scale_0_1"), False)
    probs = model.predict(ds, verbose=1)
    pred = np.argmax(probs, axis=1)
    conf = np.max(probs, axis=1)
    records = []
    hard_dir = ensure_dir(Path(out_dir) / "hard_examples" / split)
    for i, path in enumerate(paths):
        if pred[i] != y[i] and conf[i] >= min_conf:
            category = "high_confidence_wrong"
            true_label = labels[y[i]]
            pred_label = labels[pred[i]]
            if true_label.startswith("unknown__") and not pred_label.startswith("unknown__"):
                category = "unknown_as_disease"
            elif true_label.endswith("__healthy") and not pred_label.endswith("__healthy"):
                category = "healthy_as_disease"
            elif not true_label.endswith("__healthy") and pred_label.endswith("__healthy"):
                category = "disease_as_healthy"
            elif true_label.split("__")[0] != pred_label.split("__")[0]:
                category = "crop_mismatch"
            dest = hard_dir / category / path.name
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, dest)
            records.append({"path": str(path), "copy": str(dest), "trueLabel": true_label, "predictedLabel": pred_label, "confidence": float(conf[i]), "category": category})
    return records


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
    records = []
    for split in ["val", "test"]:
        records.extend(mine_split(model, args.data_dir, split, labels, meta, args.out_dir))
    if args.external_test_dir:
        records.extend(mine_split(model, args.external_test_dir, ".", labels, meta, args.out_dir))
    write_json(f"{args.out_dir}/hard_examples_report.json", {"numHardExamples": len(records), "items": records})
    print(f"Hard examples: {len(records)}")


if __name__ == "__main__":
    main()
