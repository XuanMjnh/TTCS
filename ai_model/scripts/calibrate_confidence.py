from __future__ import annotations

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[1]))

import argparse
import numpy as np
import tensorflow as tf

from src.calibration import expected_calibration_error, reliability_bins, tune_temperature
from src.data import build_tf_dataset, collect_split
from src.utils import read_json, read_labels, write_json


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data_dir", default="dataset")
    parser.add_argument("--model_path", default="outputs/model.keras")
    parser.add_argument("--out_dir", default="outputs")
    parser.add_argument("--enable_temperature", action="store_true")
    args = parser.parse_args()
    labels = read_labels(f"{args.out_dir}/labels.txt")
    meta = read_json(f"{args.out_dir}/model_meta.json")
    x, y = collect_split(args.data_dir, "val", labels)
    if not x:
        raise SystemExit("Validation set is empty.")
    ds = build_tf_dataset(x, y, meta["inputSize"], 32, meta.get("normalization", {}).get("type", "scale_0_1"), False)
    model = tf.keras.models.load_model(args.model_path)
    outputs = np.asarray(model.predict(ds, verbose=1))
    output_activation = meta.get("outputActivation", "softmax")
    if output_activation == "softmax":
        ece = expected_calibration_error(np.array(y), outputs)
        report = {"ece": ece, "reliabilityBins": reliability_bins(np.array(y), outputs), "note": "Model output is softmax; Flutter will not softmax again."}
        meta["calibration"] = {"enabled": False, "method": "none", "temperature": None, "ece": ece}
    else:
        temp, before, after = tune_temperature(np.array(y), outputs)
        report = {"temperature": temp, "eceBefore": before, "eceAfter": after, "reliabilityBins": reliability_bins(np.array(y), outputs)}
        if args.enable_temperature:
            meta["calibration"] = {"enabled": True, "method": "temperature_scaling", "temperature": temp, "eceBefore": before, "eceAfter": after}
    write_json(f"{args.out_dir}/calibration_report.json", report)
    write_json(f"{args.out_dir}/model_meta.json", meta)
    print("Calibration report written.")


if __name__ == "__main__":
    main()
