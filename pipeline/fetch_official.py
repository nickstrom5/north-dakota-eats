"""North Dakota's open official records -> data/raw/official/ (nothing to fetch today; see official.py).

Checked 2026-11-06: NDHHS's FIMS and the local units' inspection portals are search-only (linked, never scraped); the Attorney General's
retail alcohol licensee list is a PDF mixing on- and off-sale licenses, not read. This script only writes an empty meta.json so the
pipeline's steps run in order.
"""
import json, os
OUT = os.path.join(os.path.dirname(__file__), "..", "data", "raw", "official")
os.makedirs(OUT, exist_ok=True)
json.dump({}, open(os.path.join(OUT, "meta.json"), "w"))
print("North Dakota: no official list read (see official.py)")
