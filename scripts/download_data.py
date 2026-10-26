"""Download the Open e-commerce 1.0 purchases file (CC0) and verify its MD5.

Source: Berke et al. (2023), Harvard Dataverse, https://doi.org/10.7910/DVN/YGLYDY

Usage (from the project root):
    python scripts/download_data.py
"""
import hashlib
import logging
from pathlib import Path

import requests

URL = "https://dataverse.harvard.edu/api/access/datafile/7616235"
EXPECTED_MD5 = "3549d72735b1211ab009ff0177b94bd9"
OUTPUT = Path(__file__).resolve().parent.parent / "data" / "raw" / "amazon-purchases.csv"

logging.basicConfig(level=logging.INFO, format="%(levelname)s | %(message)s")
logger = logging.getLogger(__name__)


def main() -> None:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    md5 = hashlib.md5()
    with requests.get(URL, stream=True, timeout=60) as response:
        response.raise_for_status()
        with OUTPUT.open("wb") as file:
            for chunk in response.iter_content(chunk_size=1024 * 1024):
                file.write(chunk)
                md5.update(chunk)

    actual = md5.hexdigest()
    if actual != EXPECTED_MD5:
        raise SystemExit(f"MD5 mismatch: expected {EXPECTED_MD5}, got {actual}")
    logger.info("Downloaded %s (%.1f MB), MD5 verified",
                OUTPUT, OUTPUT.stat().st_size / 1e6)


if __name__ == "__main__":
    main()
