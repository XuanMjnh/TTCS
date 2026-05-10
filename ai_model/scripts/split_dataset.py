from __future__ import annotations

import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parents[1]))

import argparse
import shutil

from sklearn.model_selection import train_test_split

from src.utils import IMAGE_EXTENSIONS, ensure_dir


Record = tuple[Path, str]


def collect_raw_records(raw_dir: Path) -> list[Record]:
    records: list[Record] = []
    for label_dir in sorted(raw_dir.iterdir() if raw_dir.exists() else []):
        if not label_dir.is_dir() or "__" not in label_dir.name:
            continue
        for path in label_dir.rglob("*"):
            if path.suffix.lower() in IMAGE_EXTENSIONS:
                records.append((path, label_dir.name))
    return records


def split_records(records: list[Record]) -> tuple[list[Record], list[Record], list[Record]]:
    labels = [label for _, label in records]
    stratify = labels if len(set(labels)) > 1 else None
    train, tmp = train_test_split(records, test_size=0.30, random_state=42, stratify=stratify)

    tmp_labels = [label for _, label in tmp]
    tmp_stratify = tmp_labels if len(set(tmp_labels)) > 1 else None
    val, test = train_test_split(tmp, test_size=0.50, random_state=43, stratify=tmp_stratify)
    return train, val, test


def copy_records(records: list[Record], out_dir: Path, split: str) -> None:
    for src, label in records:
        dest = out_dir / split / label / src.name
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dest)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--raw_dir", default="dataset/raw")
    parser.add_argument("--out_dir", default="dataset")
    args = parser.parse_args()

    out = ensure_dir(args.out_dir)
    records = collect_raw_records(Path(args.raw_dir))
    if not records:
        raise SystemExit("No images found in dataset/raw.")

    train, val, test = split_records(records)
    for split, rows in [("train", train), ("val", val), ("test", test)]:
        copy_records(rows, out, split)
        print(split, len(rows))


if __name__ == "__main__":
    main()
