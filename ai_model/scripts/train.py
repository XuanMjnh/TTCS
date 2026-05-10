from __future__ import annotations

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[1]))

import argparse
import shutil
from pathlib import Path

import numpy as np
import tensorflow as tf

from src.config import TrainConfig
from src.data import augmentation_config, build_tf_dataset, collect_split, count_classes, discover_labels, make_class_weights
from src.metrics import classification_report_dict, compute_metrics, confusion_matrix_dict, warnings_for_metrics
from src.model import build_model, unfreeze_top_layers
from src.taxonomy import export_taxonomy, load_taxonomy, validate_taxonomy
from src.utils import ensure_dir, set_global_seed, write_json, write_labels


def predict_dataset(model, ds):
    probs = model.predict(ds, verbose=1)
    ys = []
    for _, y in ds.unbatch():
        ys.append(int(y.numpy()))
    return np.array(ys), np.asarray(probs)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data_dir", default="dataset")
    parser.add_argument("--arch", default="efficientnetb0", choices=["efficientnetb0", "mobilenetv2", "simple_cnn"])
    parser.add_argument("--img_size", type=int, default=224)
    parser.add_argument("--batch_size", type=int, default=32)
    parser.add_argument("--stage1_epochs", type=int, default=8)
    parser.add_argument("--stage2_epochs", type=int, default=12)
    parser.add_argument("--lr_stage1", type=float, default=1e-3)
    parser.add_argument("--lr_stage2", type=float, default=1e-5)
    parser.add_argument("--out_dir", default="outputs")
    parser.add_argument("--taxonomy_file", default=None)
    parser.add_argument("--normalization", default="auto", choices=["auto", "scale_0_1", "minus1_1", "none"])
    args = parser.parse_args()

    config = TrainConfig(img_size=args.img_size, batch_size=args.batch_size, architecture=args.arch, stage1_epochs=args.stage1_epochs, stage2_epochs=args.stage2_epochs, learning_rate_stage1=args.lr_stage1, learning_rate_stage2=args.lr_stage2)
    if args.normalization == "auto":
        if args.arch == "efficientnetb0":
            config.normalization_type = "none"
        elif args.arch == "mobilenetv2":
            config.normalization_type = "minus1_1"
    else:
        config.normalization_type = args.normalization
    set_global_seed(config.seed)
    out = ensure_dir(args.out_dir)
    taxonomy = load_taxonomy(args.taxonomy_file)
    labels = discover_labels(args.data_dir, out / "labels.txt", taxonomy)
    if not labels:
        raise SystemExit("No labels found in dataset/train. Add folders named crop__condition.")
    errors = validate_taxonomy(labels, taxonomy) if taxonomy else []
    if errors:
        print("Taxonomy warnings:")
        print("\n".join(errors))
    export_taxonomy(out / "label_taxonomy.json", labels, taxonomy)
    write_labels(out / "labels.txt", labels)

    train_x, train_y = collect_split(args.data_dir, "train", labels)
    val_x, val_y = collect_split(args.data_dir, "val", labels)
    test_x, test_y = collect_split(args.data_dir, "test", labels)
    if not train_x or not val_x:
        raise SystemExit("Train/val dataset is empty.")

    train_ds = build_tf_dataset(train_x, train_y, config.img_size, config.batch_size, config.normalization_type, training=True, seed=config.seed)
    val_ds = build_tf_dataset(val_x, val_y, config.img_size, config.batch_size, config.normalization_type, training=False)
    test_ds = build_tf_dataset(test_x, test_y, config.img_size, config.batch_size, config.normalization_type, training=False) if test_x else None

    model = build_model(config.architecture, (config.img_size, config.img_size, 3), len(labels), config)
    class_weights = make_class_weights(train_y, len(labels)) if config.use_class_weights else None
    callbacks = [
        tf.keras.callbacks.EarlyStopping(monitor="val_loss", patience=config.early_stopping_patience, restore_best_weights=True),
        tf.keras.callbacks.ReduceLROnPlateau(monitor="val_loss", patience=config.reduce_lr_patience, factor=0.3, min_lr=1e-7),
        tf.keras.callbacks.ModelCheckpoint(str(out / "best_model.keras"), monitor="val_loss", save_best_only=True),
    ]

    model.compile(optimizer=tf.keras.optimizers.Adam(config.learning_rate_stage1), loss="sparse_categorical_crossentropy", metrics=["accuracy"])
    h1 = model.fit(train_ds, validation_data=val_ds, epochs=config.stage1_epochs, class_weight=class_weights, callbacks=callbacks)

    unfreeze_top_layers(model, config.fine_tune_layers)
    model.compile(optimizer=tf.keras.optimizers.Adam(config.learning_rate_stage2), loss="sparse_categorical_crossentropy", metrics=["accuracy"])
    h2 = model.fit(train_ds, validation_data=val_ds, epochs=config.stage2_epochs, class_weight=class_weights, callbacks=callbacks)

    model.save(out / "model.keras")
    history = {k: v for k, v in h1.history.items()}
    for k, v in h2.history.items():
        history.setdefault(k, []).extend(v)
    write_json(out / "training_history.json", history)
    training_config = config.to_dict()
    training_config["augmentation"] = augmentation_config()
    write_json(out / "training_config.json", training_config)

    eval_ds = test_ds or val_ds
    y_true, probs = predict_dataset(model, eval_ds)
    metrics = compute_metrics(y_true, probs, labels)
    metrics["warnings"] = warnings_for_metrics(metrics)
    write_json(out / "metrics.json", metrics)
    write_json(out / "classification_report.json", classification_report_dict(y_true, probs, labels))
    write_json(out / "confusion_matrix.json", confusion_matrix_dict(y_true, probs, labels))

    meta = config.to_model_meta(labels, count_classes(args.data_dir, "train", labels))
    meta["trainingData"]["numTrainImages"] = len(train_x)
    meta["trainingData"]["numValImages"] = len(val_x)
    meta["trainingData"]["numTestImages"] = len(test_x)
    meta["acceptance"]["reasons"] = ["Run tune_thresholds.py, test_tflite.py and validate_export.py before production."]
    write_json(out / "model_meta.json", meta)
    print(f"Training completed. Outputs saved to {out}")


if __name__ == "__main__":
    main()
