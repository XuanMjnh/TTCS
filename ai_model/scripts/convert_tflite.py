from __future__ import annotations

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[1]))

import argparse
import tensorflow as tf

from src.utils import read_json, read_labels, write_json


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--model_path", default="outputs/model.keras")
    parser.add_argument("--out_dir", default="outputs")
    parser.add_argument("--quantization", default="float32", choices=["float32", "float16"])
    args = parser.parse_args()
    model = tf.keras.models.load_model(args.model_path)
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    if args.quantization == "float16":
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_types = [tf.float16]
    tflite_model = converter.convert()
    tflite_path = f"{args.out_dir}/model.tflite"
    open(tflite_path, "wb").write(tflite_model)

    interpreter = tf.lite.Interpreter(model_path=tflite_path)
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()[0]
    output_details = interpreter.get_output_details()[0]
    labels = read_labels(f"{args.out_dir}/labels.txt")
    report = {
        "quantization": args.quantization,
        "inputShape": input_details["shape"].tolist(),
        "inputDtype": str(input_details["dtype"]),
        "outputShape": output_details["shape"].tolist(),
        "outputDtype": str(output_details["dtype"]),
        "numLabels": len(labels),
        "outputMatchesLabels": int(output_details["shape"][-1]) == len(labels),
    }
    write_json(f"{args.out_dir}/tflite_convert_report.json", report)
    print(report)


if __name__ == "__main__":
    main()
