# Plant Disease AI 

Dự án gồm 2 phần:

- `ai_model/`: pipeline train model bằng Python/TensorFlow, đánh giá, tune threshold, calibration và export TensorFlow Lite.
- `flutter_app/`: ứng dụng Flutter tiếng Việt, chạy TFLite offline, lưu lịch sử scan/nhật ký qua Firebase.


## 1. Cài môi trường Python

```bash
cd ai_model
python -m venv .venv
# Windows
.venv\Scripts\activate
# macOS/Linux
source .venv/bin/activate
pip install -r requirements.txt
```

Yêu cầu Python 3.10/3.11, TensorFlow 2.15.1 và `numpy<2.0`.

## 2. Chuẩn bị dataset nhiều cây trồng

Cấu trúc folder bắt buộc:

```text
ai_model/dataset/train/crop__condition/*.jpg
ai_model/dataset/val/crop__condition/*.jpg
ai_model/dataset/test/crop__condition/*.jpg
ai_model/dataset/external_test/crop__condition/*.jpg  # optional
```

Label kỹ thuật phải là ASCII, lowercase, snake_case, dạng `crop__condition`


## 3. Kiểm tra chất lượng dataset

```bash
python scripts/check_dataset_quality.py --data_dir dataset --out_dir outputs
```

Script kiểm tra ảnh corrupt, quá nhỏ, quá tối/sáng, quá mờ, grayscale/sai channel, mất cân bằng class và ảnh trùng/gần trùng giữa train/val/test.

## 4. Split dataset từ thư mục raw

```bash
python scripts/split_dataset.py --raw_dir dataset/raw --out_dir dataset
```

Script đọc ảnh trực tiếp từ folder class trong `dataset/raw` và chia thành `train/val/test`.


## 5. Train model

```bash
python scripts/train.py `
  --data_dir dataset `
  --arch efficientnetb0 `
  --img_size 224 `
  --batch_size 32 `
  --stage1_epochs 8 `
  --stage2_epochs 12 `
  --out_dir outputs `
  --taxonomy_file ../flutter_app/assets/data/label_taxonomy.json
```

Kết quả gồm `model.keras`, `labels.txt`, `model_meta.json`, `training_config.json`, `metrics.json`, `classification_report.json`, `confusion_matrix.json`.

## 6. Evaluate model

```bash
python scripts/evaluate.py --data_dir dataset --model_path outputs/model.keras --out_dir outputs
python scripts/evaluate.py --data_dir dataset --external_test_dir dataset/external_test --model_path outputs/model.keras --out_dir outputs
```
## 7. Tune thresholds

```bash
python scripts/tune_thresholds.py --data_dir dataset --model_path outputs/model.keras --out_dir outputs
```

## 8. Calibration confidence

```bash
python scripts/calibrate_confidence.py --data_dir dataset --model_path outputs/model.keras --out_dir outputs
```

Nếu bật temperature scaling, metadata sẽ có `calibration.enabled=true` và `temperature` để Flutter áp dụng trước softmax nếu model output là logits.

## 9. Convert TFLite

```bash
python scripts/convert_tflite.py --model_path outputs/model.keras --out_dir outputs --quantization float32
# hoặc float16
python scripts/convert_tflite.py --model_path outputs/model.keras --out_dir outputs --quantization float16
```


## 10. Test parity Keras/TFLite

```bash
python scripts/test_tflite.py --data_dir dataset --keras_model outputs/model.keras --tflite_model outputs/model.tflite --out_dir outputs --max_samples 300
```

## 11. Validate export

```bash
python scripts/validate_export.py `
  --export_dir outputs `
  --taxonomy_file ../flutter_app/assets/data/label_taxonomy.json `
  --advice_file ../flutter_app/assets/data/advice_vi.json
```

## 12. Copy model sang Flutter

```bash
cp ai_model/outputs/model.tflite flutter_app/assets/models/model.tflite
cp ai_model/outputs/labels.txt flutter_app/assets/models/labels.txt
cp ai_model/outputs/model_meta.json flutter_app/assets/models/model_meta.json
cp ai_model/outputs/label_taxonomy.json flutter_app/assets/data/label_taxonomy.json
```

## 13. Cấu hình Firebase

```bash
cd flutter_app
flutterfire configure
```

Thay `lib/firebase/firebase_options.dart` placeholder bằng file do FlutterFire sinh ra.

Deploy rules:

```bash
firebase deploy --only firestore:rules,storage
```

## 14. Chạy Flutter

```bash
cd flutter_app
flutter create . --platforms=android
flutter pub get
flutter run
```


## 17. Bộ nhãn dataset hiện tại

Dataset mới đang có 52 nhãn thuộc 12 nhóm cây: táo, mơ, đậu, anh đào, sung, nho, sơn trà, ngô, lê, hồng, cà chua và óc chó.

Số ảnh theo split hiện tại:

```text
train: 24.815 ảnh, 52 nhãn, min 312 ảnh/nhãn, max 500 ảnh/nhãn
val:    5.322 ảnh, 52 nhãn, min 41 ảnh/nhãn, max 206 ảnh/nhãn
test:   5.345 ảnh, 52 nhãn, min 42 ảnh/nhãn, max 207 ảnh/nhãn
total: 35.482 ảnh
```