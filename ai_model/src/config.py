from __future__ import annotations

from dataclasses import asdict, dataclass
from datetime import date
from typing import Any, Optional


@dataclass
class TrainConfig:
    img_size: int = 224
    batch_size: int = 32
    seed: int = 42
    architecture: str = "efficientnetb0"
    dropout_rate: float = 0.30
    head_units: int = 256
    stage1_epochs: int = 8
    stage2_epochs: int = 12
    learning_rate_stage1: float = 1e-3
    learning_rate_stage2: float = 1e-5
    fine_tune_layers: int = 40
    use_class_weights: bool = True
    early_stopping_patience: int = 5
    reduce_lr_patience: int = 2
    weight_decay: float = 1e-5
    top_k: int = 5
    normalization_type: str = "scale_0_1"
    model_version: str = "multi_crop_disease_v1.0.0"
    labels_version: str = "labels_v1"
    taxonomy_version: str = "taxonomy_v1"
    preprocessing_version: str = "preprocess_v1"
    enable_quality_gate: bool = True
    min_sharpness: float = 80.0
    min_brightness: float = 35.0
    max_brightness: float = 230.0
    default_confidence_threshold: Optional[float] = None
    default_uncertainty_margin: Optional[float] = None
    output_activation: str = "softmax"

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)

    def to_model_meta(self, labels: list[str], class_counts: dict[str, int] | None = None) -> dict[str, Any]:
        return {
            "modelVersion": self.model_version,
            "labelsVersion": self.labels_version,
            "taxonomyVersion": self.taxonomy_version,
            "preprocessingVersion": self.preprocessing_version,
            "architecture": self.architecture,
            "inputSize": self.img_size,
            "inputChannels": 3,
            "colorFormat": "rgb",
            "resizeMode": "resize_to_square",
            "cropMode": "user_crop_or_center_crop",
            "normalization": {
                "type": self.normalization_type,
                "scale": 255.0,
                "mean": [0.0, 0.0, 0.0],
                "std": [1.0, 1.0, 1.0],
            },
            "inputDtype": "float32",
            "outputDtype": "float32",
            "outputActivation": self.output_activation,
            "labelsFile": "labels.txt",
            "taxonomyFile": "label_taxonomy.json",
            "numClasses": len(labels),
            "topK": min(self.top_k, len(labels)),
            "thresholding": {
                "method": "not_tuned_yet",
                "globalConfidenceThreshold": self.default_confidence_threshold,
                "globalUncertaintyMargin": self.default_uncertainty_margin,
                "perClassThresholdsEnabled": False,
                "perClassThresholds": {},
            },
            "qualityGate": {
                "enabled": self.enable_quality_gate,
                "minSharpness": self.min_sharpness,
                "minBrightness": self.min_brightness,
                "maxBrightness": self.max_brightness,
                "maxAnalysisDimension": 1600,
            },
            "calibration": {"enabled": False, "method": "none", "temperature": None, "ece": None},
            "trainingData": {
                "numTrainImages": 0,
                "numValImages": 0,
                "numTestImages": 0,
                "numExternalTestImages": 0,
                "classCounts": class_counts or {},
            },
            "acceptance": {
                "readyForProduction": False,
                "status": "MODEL_NOT_READY_FOR_PRODUCTION",
                "reasons": ["Thresholds and validation are not completed yet."],
            },
            "createdAt": date.today().isoformat(),
        }
