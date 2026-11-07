"""Writes data/research/app/*.json (hand-checked North Dakota guides), data/research/michelin.json, jbf.json and closed.json from the compact
lists below. Ported from ne-eats/pipeline/build_research.py.

Each entry cites the pages that name it, read on 2026-11-06: Tasting Table's best diner in every state (March 17, 2026), the Fargo-Moorhead
visitor bureau's own listings (updated January 2025), Visit Greater Grand Forks' own eateries guide, Devils Lake's visitor bureau food guide,
Medora's own dining page, Prairie Public, US 103.3 and jamesbeard.org. The Forum, the Grand Forks Herald, KFYR, KX News, Valley News Live
and Visit Minot disallow Claude in robots.txt, ndtourism.com answers with a bot check, and the Bismarck Tribune sends bots to a paid
gateway, so none is cited. Readers' polls aren't used.
The address comes from the map listing we already hold for that name in that town (site/northdakota.json); a name that isn't found exactly
once in its town (or at the street number given) is left out and listed in data/research/app/LEADS.md.
Usage: ../.venv/bin/python build_research.py   (then northdakota.py)"""
import json, os, re, unicodedata
from brands import brand_of
from common import norm_name
ROOT = os.path.join(os.path.dirname(__file__), "..")
R = os.path.join(ROOT, "data", "research")
d = json.load(open(os.path.join(ROOT, "site", "northdakota.json")))
C, M = d["cols"], d["meta"]
# accents folded ("Mångata" is "Mangata"), apostrophes dropped
norm = lambda s: re.sub(r"\s+", " ", re.sub(r"[^a-z0-9 ]", " ", unicodedata.normalize("NFKD", (s or "").lower().replace("'", "").replace("’", ""))
                                             .encode("ascii", "ignore").decode())).strip()

TT_DINER = "https://www.tastingtable.com/2123752/best-diner-every-us-state/"                              # 2026-03-17
FM = "https://www.fargomoorhead.org/listing/"
FM_KROLLS = FM + "krolls-diner/439/"                                                                     # listing, updated 2025-01-09
FM_WURST = FM + "wurst-bier-hall/9341/"                                                                  # listing, updated 2025-01-09
FM_WURST_W = FM + "wurst-bier-hall-west/11295/"                                                          # listing, updated 2025-01-09
GF_EATS = "https://www.visitgrandforks.com/blog/ten-eateries-dishing-up-forksful-of-flavor/"             # Visit Greater Grand Forks (© 2026)
DL_FOOD = "https://www.devilslakend.com/blog/post/devils-lake-food-guide/"                               # Devils Lake's visitor bureau
MEDORA_EAT = "https://medora.com/eat/"                                                                   # Medora's own dining page (© 2026)
PP_BIS = "https://news.prairiepublic.org/podcast/prairie-plates/2026-08-05/two-restaurants-to-open-in-iconic-bismarck-locations"   # 2026-08-05
US1033_HUCK = "https://us1033.com/bismarck-waterfront-dining-update/"                                     # 2026-05-08
JBF25 = "https://www.jamesbeard.org/stories/the-2025-james-beard-award-semifinalists"                    # 2025-01-22
FARGO, BIS, GF = "Fargo", "Bismarck", "Grand Forks"

GUIDES = {
 "knoephla kuchen": [   # German-Russian dishes: knoephla (potato-dumpling soup), fleischkuechle, kuchen
  ("Kroll's Diner", FARGO, "1033", "Tasting Table's pick for North Dakota's best diner (March 2026), for German specialties like its knoephla "
   "soup; the Fargo-Moorhead visitor bureau adds fleischkuechle.", None, None, [TT_DINER, FM_KROLLS]),
  ("Kroll's Diner", BIS, None, "Tasting Table's pick for North Dakota's best diner (March 2026), a chain with several North Dakota diners, for "
   "German specialties like its knoephla soup.", None, None, [TT_DINER]),
  ("Kroll's Diner", "Mandan", None, "Tasting Table's pick for North Dakota's best diner (March 2026), a chain with several North Dakota diners, "
   "for German specialties like its knoephla soup.", None, None, [TT_DINER]),
  ("Kroll's Diner", "Minot", None, "Tasting Table's pick for North Dakota's best diner (March 2026), a chain with several North Dakota diners, "
   "for German specialties like its knoephla soup.", None, None, [TT_DINER]),
  ("Wurst Bier Hall", FARGO, "630", "A German bier hall downtown: beer by the boot, sausages, sauerkraut, and knoephla and borscht soups "
   "(Fargo-Moorhead visitor bureau).", None, None, [FM_WURST]),
  ("Wurst Bier Hall West", "West Fargo", "3179", "The West Fargo bier hall: sausages, sauerkraut, and knoephla and borscht soups "
   "(Fargo-Moorhead visitor bureau).", None, None, [FM_WURST_W]),
  ("Darcy's Cafe", GF, None, "A breakfast-and-lunch café with knoephla soup and hot beef sandwiches (Visit Greater Grand Forks).", None, None,
   [GF_EATS])],
 "steak walleye": [   # steakhouses and walleye
  ("Harry's Steakhouse", GF, None, "Downtown Grand Forks's steakhouse, with Harry's-style hash browns (Visit Greater Grand Forks).", None, None, [GF_EATS]),
  ("Ely's Ivy", GF, None, "Honey pan-fried walleye and a teres major steak (Visit Greater Grand Forks).", None, None, [GF_EATS]),
  ("The Ranch Steakhouse", "Devils Lake", None, "Prime rib served every day until it's gone, Devils Lake's visitor bureau says.", None, None, [DL_FOOD]),
  ("Theodore's Dining Room", "Medora", None, "Bacon-wrapped steaks and bison osso buco, open year-round in Medora (Medora's own page).", None, None,
   [MEDORA_EAT]),
  ("Pitchfork Steak Fondue", "Medora", None, "Steaks cooked on pitchforks at a seasonal cowboy cookout; Medora's own page says it reopens in "
   "June 2027.", None, None, [MEDORA_EAT])],
 "oldest": [],
}
ADDR = {}
CUISINE = {("Pitchfork Steak Fondue", "Medora"): "Steakhouse"}
KINDS = {k: [k] for k in ("knoephla kuchen", "steak walleye", "oldest")}

# MICHELIN: no guide covers North Dakota (guide.michelin.com/us/en/north-dakota/restaurants answered 404 in September 2026)
MICHELIN = []
MI_MATCH = {}
MI_UT = None
JBF = [{"name": "Luna Fargo", "city": FARGO, "address": "1545 S University Dr",
        "honors": ["Outstanding Restaurateur semifinalist 2025 (Nikki Berglund and Ryan Nitschke)"], "sources": [JBF25]}]
CLOSED = [{"name": "Peacock Alley", "address": "422 E Main Ave", "city": BIS, "match_names": ["PEACOCK ALLEY", "PEACOCK ALLEY AMERICAN GRILL AND BAR",
                                                                                              "PEACOCK ALLEY AMERICAN GRILL & BAR"],
           "closed_reason": "Left its downtown home in the Patterson Hotel in 2026; McKenzie Steakhouse is opening in the former Peacock Alley space "
                            "on Main Avenue.", "sources": [PP_BIS]},
          {"name": "Huckleberry House", "address": "1700 River Rd", "city": BIS, "match_names": ["HUCKLEBERRY HOUSE"],
           "closed_reason": "Closed late in 2025; The Landing Restaurant & Bar is moving into its space at 1700 River Road.", "sources": [US1033_HUCK]}]


def key(s):
    """The name key without a leading "the": "Varsity" is our "The Varsity"."""
    return re.sub(r"\s+", " ", re.sub(r"\band\b", " ", re.sub(r"^the ", "", norm(s)))).strip()   # "Don & Millie's" is "Don and Millies"


def find(name, town, num):
    k = key(name)
    hits = [i for i, n in enumerate(C["name"]) if C["city"][i] is not None and M["cities"][C["city"][i]] == town
            and (key(n) == k or key(n).startswith(k + " ") or k.startswith(key(n) + " ") or key(n).replace(" ", "") == k.replace(" ", "")
                 or (key(n).split()[:2] == k.split()[:2] and len(k.split()) >= 2))]
    if num:
        hits = [i for i in hits if (C["addr"][i] or "").split(" ")[0] == num]
    return hits


leads, n_out = [], {}
for kind, rows in GUIDES.items():
    out = []
    for name, town, num, note, founded, fnote, srcs in rows:
        hits = find(name, town, num)
        if not hits and (name, town) in ADDR:
            out.append({"name": name, "address": ADDR[(name, town)], "city": town, "zip": None, "kinds": KINDS[kind], "dishes": [], "note": note,
                        "founded": founded, "founded_note": fnote, "website": None, "open": True, "evidence_date": "2026-10",
                        "sources": srcs, "match_names": []} | ({"cuisine": CUISINE[(name, town)]} if (name, town) in CUISINE else {}))
            continue
        if len(hits) != 1:
            leads.append(f"- {kind}: {name} ({town}{', ' + num if num else ''}) — {len(hits)} matches in our data; not added"); continue
        i = hits[0]
        out.append({"name": C["name"][i], "address": C["addr"][i], "city": town, "zip": str(C["zip"][i]) if C["zip"][i] else None,
                    "kinds": KINDS[kind], "dishes": [], "note": note, "founded": founded, "founded_note": fnote, "website": None, "open": True,
                    "evidence_date": "2026-10", "sources": srcs, "match_names": [name.upper()] if norm(name) != norm(C["name"][i]) else []})
        if brand_of(norm_name(name)):   # a chain shows under its own spelling at every branch, whatever the listing says
            out[-1]["display"] = name
        if (name, town) in CUISINE:
            out[-1]["cuisine"] = CUISINE[(name, town)]
    fn = re.sub(r"[^a-z]+", "_", kind).strip("_")
    json.dump(out, open(f"{R}/app/{fn}.json", "w"), indent=1, ensure_ascii=False)
    n_out[kind] = len(out)

MI_ADDR = {}
json.dump({"restaurants": [{"name": n, "address": MI_ADDR.get(n), "city": t, "zip": None, "distinction": dist, "cuisine": cu, "green_star": False,
                             "michelin_url": MI_UT, "sources": [MI_UT], "match_names": [x.upper() for x in MI_MATCH.get(n, [])], "open": True}
                            for n, t, dist, cu in MICHELIN]}, open(f"{R}/michelin.json", "w"), indent=1, ensure_ascii=False)
json.dump([dict({"address": None}, **j, zip=None, open=True) for j in JBF], open(f"{R}/jbf.json", "w"), indent=1, ensure_ascii=False)
json.dump(CLOSED, open(f"{R}/closed.json", "w"), indent=1, ensure_ascii=False)
open(f"{R}/app/LEADS.md", "w").write("# North Dakota research leads (not yet verified)\n\nWritten by pipeline/build_research.py.\n\n" + "\n".join(leads) + """

## Waiting for a source we may use, or for the map data
- Knoephla and kuchen: Little Cottage Café (Bismarck; Prairie Public, 2022) and Tellmann's Market (New Salem) have no 2025-26 page;
  the Fargo-Moorhead visitor bureau's Midwestern-food story (Blarney Stone, Cracked Pepper, Prairie Kitchen's lefse) is from 2023.
- Walleye: Devils Lake's own pages name Ed's Bar and Bait (it fries your catch) and Cedar Inn's walleye nights without a 2025-26 page.
- Rhubarb and chokecherry pies, Native-owned restaurants and frybread: no 2025-26 page we may cite names a place (Native ownership needs
  the business's or tribe's word).
- James Beard: Mångata Wine & Raw Bar (inside Brewhalla, Fargo; the same 2025 restaurateur semifinal as Luna Fargo) isn't in the
  map data; Sol Ave. Kitchen is in Moorhead, Minnesota.
- Oldest: Peacock Alley (Bismarck, 1933) left its downtown home in 2026 (closed list); no other place has a dated year at its address.
- Blocked or unusable hosts: inforum.com, grandforksherald.com, jamestownsun.com, thedickinsonpress.com, willistonherald.com, kfyrtv.com,
  valleynewslive.com, kxnet.com, kvrr.com and visitminot.org disallow Claude; ndtourism.com answers with a bot check; bismarcktribune.com
  sends bots to a paid gateway (TollBit), so it isn't cited.
- Official data: NDHHS's FIMS and the local units' portals are search-only; First District's official scores answer 403 to scripts; the
  Attorney General's licensee PDF mixes on- and off-sale licenses. A records request is Nick's call.
""")
print(n_out, "| leads:", len(leads))
for l in leads: print(l)
