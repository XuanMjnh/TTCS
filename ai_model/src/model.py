from __future__ import annotations

import tensorflow as tf

from .config import TrainConfig


def _classification_head(x, num_classes: int, config: TrainConfig):
    x = tf.keras.layers.GlobalAveragePooling2D(name="gap")(x)
    x = tf.keras.layers.BatchNormalization(name="head_bn")(x)
    x = tf.keras.layers.Dense(config.head_units, activation="swish", kernel_regularizer=tf.keras.regularizers.l2(config.weight_decay), name="head_dense")(x)
    x = tf.keras.layers.Dropout(config.dropout_rate, name="head_dropout")(x)
    activation = "softmax" if config.output_activation == "softmax" else None
    return tf.keras.layers.Dense(num_classes, activation=activation, name="predictions")(x)


def build_simple_cnn(input_shape: tuple[int, int, int], num_classes: int, config: TrainConfig):
    inputs = tf.keras.Input(shape=input_shape, name="image")
    x = inputs
    for filters in [32, 64, 128, 192]:
        x = tf.keras.layers.Conv2D(filters, 3, padding="same", activation="swish")(x)
        x = tf.keras.layers.BatchNormalization()(x)
        x = tf.keras.layers.MaxPooling2D()(x)
    x = _classification_head(x, num_classes, config)
    return tf.keras.Model(inputs, x, name="simple_cnn_leaf_disease")


def build_mobilenetv2_transfer(input_shape: tuple[int, int, int], num_classes: int, config: TrainConfig):
    inputs = tf.keras.Input(shape=input_shape, name="image")
    backbone = tf.keras.applications.MobileNetV2(include_top=False, weights="imagenet", input_tensor=inputs)
    backbone.trainable = False
    outputs = _classification_head(backbone.output, num_classes, config)
    return tf.keras.Model(inputs, outputs, name="mobilenetv2_leaf_disease")


def build_efficientnetb0_transfer(input_shape: tuple[int, int, int], num_classes: int, config: TrainConfig):
    inputs = tf.keras.Input(shape=input_shape, name="image")
    backbone = tf.keras.applications.EfficientNetB0(include_top=False, weights="imagenet", input_tensor=inputs)
    backbone.trainable = False
    outputs = _classification_head(backbone.output, num_classes, config)
    return tf.keras.Model(inputs, outputs, name="efficientnetb0_leaf_disease")


def build_model(architecture: str, input_shape: tuple[int, int, int], num_classes: int, config: TrainConfig):
    arch = architecture.lower()
    if arch == "simple_cnn":
        return build_simple_cnn(input_shape, num_classes, config)
    if arch == "mobilenetv2":
        return build_mobilenetv2_transfer(input_shape, num_classes, config)
    if arch == "efficientnetb0":
        return build_efficientnetb0_transfer(input_shape, num_classes, config)
    raise ValueError(f"Unsupported architecture: {architecture}")


def unfreeze_top_layers(model: tf.keras.Model, fine_tune_layers: int) -> None:
    # Keep all BatchNormalization layers frozen for stable fine-tuning.
    trainable_count = 0
    for layer in reversed(model.layers):
        if trainable_count >= fine_tune_layers:
            break
        if isinstance(layer, tf.keras.layers.BatchNormalization):
            layer.trainable = False
            continue
        if "predictions" in layer.name or "head_" in layer.name:
            continue
        layer.trainable = True
        trainable_count += 1
    for layer in model.layers:
        if isinstance(layer, tf.keras.layers.BatchNormalization):
            layer.trainable = False
