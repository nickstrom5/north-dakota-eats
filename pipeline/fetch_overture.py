"""Download the Overture Maps extracts that northdakota.py reads -> data/nd/

- overture_nd_bbox.parquet     every place in North Dakota's bounding box (name, category, address, point)
- overture_nd_sources.parquet  which datasets each North Dakota eating/drinking listing came from (Meta, Foursquare, ...)
- nd_shapes.json               simplified state and county outlines for the map
- nd_state_detail.geojson      the state outline at full detail, for the in-state test

Reads the public Overture bucket over S3 with DuckDB (no account needed). Ported from mn-eats/pipeline/fetch_overture.py.
North Dakota: land division areas; the "counties" are its 53. The script checks the towns on the Red River (Fargo and Moorhead, Grand
Forks and East Grand Forks, Wahpeton and Breckenridge), the Montana line (Williston, Beach; Sidney and Fairview, MT), the South Dakota
line and the Canadian border, so a Minnesota, Montana, South Dakota, Manitoba or Saskatchewan listing stays out.
"""
import os, json, time
import duckdb
from shapely import wkb
from shapely.geometry import mapping, Polygon

RELEASE = "2026-10-21.0"
OUT = os.path.join(os.path.dirname(__file__), "..", "data", "nd")
# North Dakota (45.94°N–49.00°N, 96.55°W–104.05°W) plus a margin for the Red River towns and the borders
BBOX = "bbox.xmin BETWEEN -104.3 AND -96.3 AND bbox.ymin BETWEEN 45.8 AND 49.1"
EAT = "('restaurant','casual_eatery','bar','fast_food_restaurant','coffee_shop','cafe','smoothie_juice_bar','brewery','food_court')"
os.makedirs(OUT, exist_ok=True)

con = duckdb.connect()
con.execute("INSTALL httpfs; LOAD httpfs; INSTALL spatial; LOAD spatial; SET s3_region='us-west-2';")
places = f"s3://overturemaps-us-west-2/release/{RELEASE}/theme=places/type=place/*.parquet"

t = time.time()
if not os.path.exists(f"{OUT}/overture_nd_bbox.parquet"):
    con.execute(f"""
COPY (
  SELECT id, names.primary AS name, basic_category AS cat, taxonomy.primary AS tax, taxonomy.hierarchy AS hier, confidence,
         operating_status AS status, brand.names.primary AS brand, addresses[1].freeform AS street, addresses[1].locality AS city,
         addresses[1].postcode AS zip, addresses[1].region AS region, ST_Y(geometry) AS lat, ST_X(geometry) AS lon, websites[1] AS web,
         phones[1] AS phone
  FROM read_parquet('{places}', hive_partitioning=1) WHERE {BBOX}
) TO '{OUT}/overture_nd_bbox.parquet' (FORMAT PARQUET)""")
    print("places in bbox", round(time.time() - t), "s", flush=True)
if not os.path.exists(f"{OUT}/overture_nd_sources.parquet"):
    con.execute(f"""
COPY (
  SELECT id, list_transform(sources, lambda x: x.dataset) AS ds, list_transform(sources, lambda x: x.update_time) AS ut,
         list_transform(sources, lambda x: x.record_id) AS rid,
         len(socials) AS n_soc, len(websites) AS n_web, len(phones) AS n_ph
  FROM read_parquet('{places}', hive_partitioning=1)
  WHERE {BBOX} AND basic_category IN {EAT}
) TO '{OUT}/overture_nd_sources.parquet' (FORMAT PARQUET)""")
    print("sources", round(time.time() - t), "s", flush=True)

areas = f"s3://overturemaps-us-west-2/release/{RELEASE}/theme=divisions/type=division_area/*.parquet"
rows = con.execute(f"""
  SELECT subtype, names.primary AS name, ST_AsWKB(geometry) AS g
  FROM read_parquet('{areas}', hive_partitioning=1)
  WHERE country = 'US' AND region = 'US-ND' AND subtype IN ('region', 'county') AND class = 'land'
    AND bbox.xmin > -104.4 AND bbox.xmax < -96.2 AND bbox.ymin > 45.7 AND bbox.ymax < 49.2""").fetchall()


def rings(geom, tol, min_area):
    geom = geom.simplify(tol, preserve_topology=True)
    polys = [p for p in getattr(geom, "geoms", [geom]) if p.geom_type == "Polygon" and p.area >= min_area]
    return [[[round(x, 3), round(y, 3)] for x, y in p.exterior.coords] for p in polys]


out = {"state": None, "counties": []}
for sub, name, g in rows:
    geom = wkb.loads(bytes(g)).buffer(0)
    if sub == "region":
        json.dump(mapping(geom.simplify(0.0005, preserve_topology=True)), open(f"{OUT}/nd_state_detail.geojson", "w"))
        out["state"] = [[r] for r in rings(geom, 0.002, 0.000005)]
    else:
        out["counties"].append({"name": name, "c": rings(geom, 0.004, 0.00002)})
# full-detail county polygons for assigning each place to a county (not shipped)
json.dump({name: mapping(wkb.loads(bytes(g)).buffer(0).simplify(0.0003, preserve_topology=True))
           for sub, name, g in rows if sub == "county"}, open(f"{OUT}/nd_counties_detail.geojson", "w"))
json.dump(out, open(f"{OUT}/nd_shapes.json", "w"), separators=(",", ":"))
print("outlines: state", len(out["state"] or []), "rings +", len(out["counties"]), "counties;", round(time.time() - t), "s total")
# border towns: each must fall on the right side of the detailed state outline
from shapely.geometry import shape, Point
st = shape(json.load(open(f"{OUT}/nd_state_detail.geojson")))
for nm, lon, lat, want in [("Fargo", -96.7898, 46.8772, True), ("West Fargo", -96.9003, 46.8750, True), ("Grand Forks", -97.0329, 47.9253, True),
                           ("Wahpeton", -96.6059, 46.2652, True), ("Pembina", -97.2434, 48.9664, True), ("Williston", -103.6180, 48.1470, True),
                           ("Beach", -104.0044, 46.9183, True), ("Hankinson", -96.9017, 46.0705, True), ("Portal", -102.5488, 48.9958, True),
                           ("Moorhead, MN", -96.7676, 46.8738, False), ("East Grand Forks, MN", -97.0244, 47.9300, False),
                           ("Breckenridge, MN", -96.5884, 46.2633, False), ("Sidney, MT", -104.1564, 47.7167, False), ("Fairview, MT", -104.0469, 47.8547, False),
                           ("Lemmon, SD", -102.1593, 45.9408, False), ("Emerson, MB", -97.2116, 49.0050, False), ("North Portal, SK", -102.5527, 49.0006, False)]:
    ok = st.contains(Point(lon, lat))
    print(f"  {nm}: {'inside' if ok else 'outside'}{'' if ok == want else '  <-- WRONG'}")
print("counties:", len(out["counties"]), sorted(c["name"] for c in out["counties"]))

# the neighbours' land (Minnesota, Montana, South Dakota, Manitoba, Saskatchewan): listings.py widens North Dakota's outline ~300 m for
# river banks, but only where no neighbour's land is, so a Moorhead or East Grand Forks listing across the Red River stays out
nb = con.execute(f"""
  SELECT region, ST_AsWKB(geometry) FROM read_parquet('{areas}', hive_partitioning=1)
  WHERE ((country = 'US' AND region IN ('US-MN', 'US-MT', 'US-SD')) OR (country = 'CA' AND region IN ('CA-MB', 'CA-SK'))) AND subtype = 'region' AND class = 'land'""").fetchall()
from shapely.ops import unary_union
from shapely.geometry import box
near = box(-104.6, 45.6, -96.0, 49.4)
nbg = unary_union([wkb.loads(bytes(g)).buffer(0).intersection(near) for _, g in nb])
json.dump(mapping(nbg.simplify(0.0002, preserve_topology=True)), open(f"{OUT}/nd_neighbors.geojson", "w"))
print("neighbours:", sorted(r for r, _ in nb))
