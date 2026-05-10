from __future__ import annotations

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[1]))

import argparse
from pathlib import Path

import numpy as np
import tensorflow as tf

from src.data import collect_split
from src.preprocessing import preprocess_batch
from src.utils import read_json, read_labels, write_json


def run_tflite(model_path, batch):
    interpreter = tf.lite.Interpreter(model_path=model_path)
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()[0]
    output_details = interpreter.get_output_details()[0]
    outputs = []
    for sample in batch:
        x = np.expand_dims(sample, 0).astype(input_details["dtype"])
        interpreter.set_tensor(input_details["index"], x)
        interpreter.invoke()
        outputs.append(interpreter.get_tensor(output_details["index"])[0])
    return np.asarray(outputs)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data_dir", default="dataset")
    parser.add_argument("--keras_model", default="outputs/model.keras")
    parser.add_argument("--tflite_model", default="outputs/model.tflite")
    parser.add_argument("--out_dir", default="outputs")
    parser.add_argument("--max_samples", type=int, default=300)
    args = parser.parse_args()
    labels = read_labels(Path(args.out_dir) / "labels.txt")
    meta = read_json(Path(args.out_dir) / "model_meta.json")
    paths, _ = collect_split(args.data_dir, "test", labels)
    paths = paths[: args.max_samples]
    if not paths:
        raise SystemExit("No test images found.")
    batch = preprocess_batch(paths, meta["inputSize"], meta.get("normalization", {}).get("type", "scale_0_1"))
    keras = tf.keras.models.load_model(args.keras_model)
    keras_probs = keras.predict(batch, verbose=0)
    tflite_probs = run_tflite(args.tflite_model, batch)
    k_top = np.argmax(keras_probs, axis=1)
    t_top = np.argmax(tflite_probs, axis=1)
    mismatch = np.where(k_top != t_top)[0]
    report = {
        "numSamples": len(paths),
        "top1MatchRate": float(np.mean(k_top == t_top)),
        "meanAbsoluteDifference": float(np.mean(np.abs(keras_probs - tflite_probs))),
        "maxAbsoluteDifference": float(np.max(np.abs(keras_probs - tflite_probs))),
        "numTop1Mismatch": int(len(mismatch)),
        "top1Mismatches": [{"path": str(paths[i]), "kerasTop1": labels[int(k_top[i])], "tfliteTop1": labels[int(t_top[i])]} for i in mismatch[:100]],
    }
    write_json(Path(args.out_dir) / "tflite_parity_report.json", report)
    print(report)


if __name__ == "__main__":
    main()
