from __future__ import annotations

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[1]))

import argparse
import numpy as np
import tensorflow as tf

from src.data import build_tf_dataset, collect_split
from src.thresholding import apply_threshold_to_meta, tune_thresholds_from_validation
from src.utils import read_json, read_labels, write_json


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data_dir", default="dataset")
    parser.add_argument("--model_path", default="outputs/model.keras")
    parser.add_argument("--out_dir", default="outputs")
    args = parser.parse_args()
    labels = read_labels(f"{args.out_dir}/labels.txt")
    meta = read_json(f"{args.out_dir}/model_meta.json")
    x, y = collect_split(args.data_dir, "val", labels)
    if not x:
        raise SystemExit("Validation set is empty.")
    ds = build_tf_dataset(x, y, meta["inputSize"], 32, meta.get("normalization", {}).get("type", "scale_0_1"), False)
    model = tf.keras.models.load_model(args.model_path)
    probs = model.predict(ds, verbose=1)
    thresholds = tune_thresholds_from_validation(np.array(y), np.asarray(probs), labels)
    write_json(f"{args.out_dir}/thresholds.json", thresholds)
    meta = apply_threshold_to_meta(meta, thresholds)
    write_json(f"{args.out_dir}/model_meta.json", meta)
    print("Thresholds tuned from validation set.")


if __name__ == "__main__":
    main()
