from __future__ import annotations

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[1]))

import argparse
from src.quality import dataset_quality_report


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data_dir", default="dataset")
    parser.add_argument("--out_dir", default="outputs")
    args = parser.parse_args()
    report = dataset_quality_report(args.data_dir, args.out_dir)
    print(f"Quality report written. Images={report['numImages']} issues={report['numIssues']}")


if __name__ == "__main__":
    main()
