from __future__ import annotations

from pathlib import Path
from typing import Any

import numpy as np
from sklearn.utils.class_weight import compute_class_weight

from .utils import list_image_files, read_labels, write_labels


def discover_labels(data_dir: str | Path, out_labels_path: str | Path | None = None, preferred_taxonomy: dict[str, Any] | None = None) -> list[str]:
    data_dir = Path(data_dir)
    train_dir = data_dir / "train"
    folder_labels = sorted([p.name for p in train_dir.iterdir() if p.is_dir() and "__" in p.name]) if train_dir.exists() else []
    if out_labels_path and Path(out_labels_path).exists():
        existing_labels = read_labels(out_labels_path)
        if existing_labels and set(existing_labels) == set(folder_labels):
            return existing_labels
    if preferred_taxonomy:
        preferred = [label for label in preferred_taxonomy.keys() if label in folder_labels]
        rest = [label for label in folder_labels if label not in preferred]
        labels = preferred + rest
    else:
        labels = folder_labels
    if out_labels_path:
        write_labels(out_labels_path, labels)
    return labels


def collect_split(data_dir: str | Path, split: str, labels: list[str]) -> tuple[list[Path], list[int]]:
    base = Path(data_dir) / split
    label_to_index = {label: i for i, label in enumerate(labels)}
    xs: list[Path] = []
    ys: list[int] = []
    for label in labels:
        folder = base / label
        for path in list_image_files(folder):
            xs.append(path)
            ys.append(label_to_index[label])
    return xs, ys


def count_classes(data_dir: str | Path, split: str, labels: list[str]) -> dict[str, int]:
    paths, ys = collect_split(data_dir, split, labels)
    counts = {label: 0 for label in labels}
    for y in ys:
        counts[labels[y]] += 1
    return counts


def make_class_weights(y_train: list[int], num_classes: int) -> dict[int, float] | None:
    if not y_train:
        return None
    classes = np.arange(num_classes)
    weights = compute_class_weight(class_weight="balanced", classes=classes, y=np.array(y_train))
    return {int(i): float(w) for i, w in enumerate(weights)}


def build_tf_dataset(paths: list[Path], labels: list[int], img_size: int, batch_size: int, normalization_type: str = "scale_0_1", training: bool = False, seed: int = 42):
    import tensorflow as tf

    path_ds = tf.data.Dataset.from_tensor_slices([str(p) for p in paths])
    label_ds = tf.data.Dataset.from_tensor_slices(labels)
    ds = tf.data.Dataset.zip((path_ds, label_ds))

    def load_and_preprocess(path, label):
        image = tf.io.read_file(path)
        image = tf.image.decode_image(image, channels=3, expand_animations=False)
        image = tf.image.resize(image, [img_size, img_size], method="bilinear")
        image = tf.cast(image, tf.float32)
        if normalization_type == "scale_0_1":
            image = image / 255.0
        elif normalization_type == "minus1_1":
            image = (image / 127.5) - 1.0
        elif normalization_type == "none":
            pass
        else:
            raise ValueError(f"Unsupported normalization: {normalization_type}")
        return image, label

    ds = ds.map(load_and_preprocess, num_parallel_calls=tf.data.AUTOTUNE)
    if training:
        aug = tf.keras.Sequential([
            tf.keras.layers.RandomFlip("horizontal"),
            tf.keras.layers.RandomRotation(0.05),
            tf.keras.layers.RandomTranslation(0.05, 0.05),
            tf.keras.layers.RandomZoom(0.08),
            tf.keras.layers.RandomContrast(0.08),
        ], name="leaf_safe_augmentation")

        def augment(image, label):
            image = aug(image, training=True)
            if normalization_type == "none":
                noise = tf.random.normal(tf.shape(image), mean=0.0, stddev=2.55, seed=seed)
                image = tf.clip_by_value(image + noise, 0.0, 255.0)
            else:
                noise = tf.random.normal(tf.shape(image), mean=0.0, stddev=0.01, seed=seed)
                image = tf.clip_by_value(image + noise, 0.0, 1.0)
            return image, label

        ds = ds.shuffle(min(len(paths), 2048), seed=seed, reshuffle_each_iteration=True)
        ds = ds.map(augment, num_parallel_calls=tf.data.AUTOTUNE)
    ds = ds.batch(batch_size).prefetch(tf.data.AUTOTUNE)
    return ds


def augmentation_config() -> dict[str, Any]:
    return {
        "RandomFlip": "horizontal",
        "RandomRotation": 0.05,
        "RandomTranslation": 0.05,
        "RandomZoom": 0.08,
        "RandomContrast": 0.08,
        "GaussianNoiseStd": 0.01,
        "Notes": "Light leaf-safe augmentation. Avoid strong color shift, heavy blur, or small crop that removes disease region.",
    }
