# North Dakota Eats (nd-eats) — notes for Claude Code sessions

Built 2026-11-06 by a side session for Nick's "build the 17 states left" (group: MN, IA, NE, ND, SD).
- Ported from `../ia-eats/`, with no official list and no inspection results.
- It carries every fix through 11-05: the exact-outline county lookup, the out-of-county truck rule, Utah's street-word merge fix,
  Vermont's narrowed "dejavu" rule, Virginia's near-adult-venue fix, the per-state ZIP check, the delivery-only brands, the website
  blocklist and `link_blocklist.py`, the Share link `Links.site + explore/#p=<id>`, OTA data and the adult-venue rules.
- It also has wy-eats' far-listing rule.
- Local only: git-ignored data, no repo, no remote, nothing published. Sources: `playbook/12-sources.md`.

Brand: `playbook/05-naming.md` — **final**, Nick's decision of 2026-11-07: name, knoephla icon (A) and palette exactly as built.
- Name: "North Dakota Eats: Restaurants", Home Screen "ND Eats".
- Icon: a bowl of knoephla.
- Palette: big-sky blue #1E4F8C, scoria red #A63D2A, sunflower gold #E8B83A (fill only) and cream #F7F2E6.
- Header band: a prairie horizon with a grain elevator.

## North Dakota is different
- **No Google data at all** (rule of 2026-11-06). The UCSD snapshot is never downloaded, and `listings.py` builds an empty Google
  table. The keep rule is the family's: Meta 0.95, or 0.90 with a website.
- **No official list:**
  - Nine inspection systems run in the state (NDHHS plus eight local units), and all are search-only. First District's official
    scores answer 403 to scripts.
  - Every place links NDHHS's food and lodging page (`Links.inspections`). Places on tribal lands are under tribal jurisdiction, and
    the app says so.
  - The Attorney General's alcohol licensee list is a PDF that mixes on- and off-sale licenses, so it isn't read. "Serves alcohol" is
    "—" everywhere.
  - A records request is Nick's call.
- **Counties and regions:** 53 counties and six detail files (Red River Valley, Bismarck-Mandan, Minot & North Central, Lakes &
  Southeast, Oil Patch & Northwest, Badlands & Southwest).
  - `fetch_overture.py` checks the border towns: Fargo, Grand Forks, Wahpeton, Pembina, Williston, Beach and Portal are in; Moorhead,
    East Grand Forks, Breckenridge, Sidney, Fairview, Lemmon, Emerson and North Portal are out.
  - The app's outline is simplified before the neighbours' land is cut out. Simplifying afterwards let Fairview, MT in.
- **Venues:**
  - Hector International, Bismarck, Grand Forks and Minot airports.
  - The Fargodome, the Alerus Center and Ralph Engelstad Arena, the Bismarck Event Center, and the State Fair (Minot).
  - Each venue address counts only in its own town.
  - Grocery and gas counters (Hornbacher's, Cash Wise, Hugo's, Casey's) are hidden as stores.
- **Adult venues:** The Northern Cabaret and The Bomb Shelter (its website is the Cabaret's) share 325 10th St N, Fargo.
- **Addresses:** `common.nice` keeps highway capitals ("1119 ND-20").
- **Guides** (tags in `northdakota.py` TAGS: knoephla 1, steaks 2, oldest 4; sources in `pipeline/build_research.py`, each note checked
  against its page on 2026-11-06):
  - Knoephla & Kuchen (6):
    - Kroll's Diner (Fargo, Mandan, Minot), Tasting Table's best diner in the state (March 2026).
    - Wurst Bier Hall (Fargo, West Fargo), from the Fargo-Moorhead visitor bureau's listings.
    - Darcy's Cafe (Grand Forks).
  - Steaks & Walleye (5):
    - Harry's Steakhouse and Ely's Ivy (Grand Forks).
    - The Ranch Steakhouse (Devils Lake).
    - Theodore's Dining Room and the seasonal Pitchfork Steak Fondue (Medora).
  - North Dakota's 2025-26 sources are thin. The leads (pies, Native-owned kitchens, Little Cottage Café, Devils Lake walleye) are in
    `data/research/app/LEADS.md`.
- **Closed:**
  - Peacock Alley, Bismarck (1933, Tasting Table's oldest in the state) left its downtown home in 2026, and McKenzie Steakhouse is
    taking the space.
  - Huckleberry House, Bismarck closed late in 2025; its chef was a 2025 James Beard semifinalist.
  - With those gone, there's no Oldest list.
- **Honors:** no MICHELIN Guide covers North Dakota. James Beard: Luna Fargo's restaurateurs, Outstanding Restaurateur semifinalists
  in 2025.
  - The chip reads "James Beard (restaurateur)".
  - Mångata (inside Brewhalla) isn't in the map data, and their Sol Ave. Kitchen is in Moorhead, MN.
- **Cities:** city pages need 3 hand-checked or honored places, not the family's 4, because North Dakota's lists are short. Fargo and
  Grand Forks have pages.

## Rebuild
```bash
cd pipeline
../.venv/bin/python fetch_overture.py && ../.venv/bin/python fetch_extras.py && ../.venv/bin/python fetch_official.py
../.venv/bin/python geocode_official.py && ../.venv/bin/python listings.py && ../.venv/bin/python calibrate.py
../.venv/bin/python northdakota.py && ../.venv/bin/python build_research.py && ../.venv/bin/python northdakota.py
ND_APP=1 ../.venv/bin/python northdakota.py && cd .. && cp data/app/places.json data/app/detail-*.json NorthDakotaEats/Resources/
.venv/bin/python pipeline/check_websites.py && .venv/bin/python pipeline/check_websites.py --retry-transient   # then re-export
.venv/bin/python scripts/make-site.py && .venv/bin/python scripts/publish_app_data.py && .venv/bin/python scripts/publish_app_data.py --check
.venv/bin/python scripts/qa-site.py --static && .venv/bin/python scripts/qa-site.py   # the second runs headless Chrome (Playwright)
```
- `data/chain_auv.json` is a copy of wy-eats'.
- `fetch_overture.py` skips any file that already exists, so delete both parquets together when the box changes.

## App, site, screenshots
- **App:** `NorthDakotaEats/`.
  - XcodeGen `project.yml`, bundle `com.northdakotaeats.ios`, display name "ND Eats".
  - Tests are in `NorthDakotaEatsTests/` (a 12-place North Dakota fixture plus the family's data guards) and `NorthDakotaEatsUITests/`.
  - Build and test only with Xcode 1.app (27.2, 27B52).
  - xcodegen writes Info.plist from `project.yml`.
- **Site:** `scripts/make-site.py` writes `docs/`. `scripts/explore.js` is the web app, and `scripts/qa-site.py` the QA.
  - Site URL for now: nickstrom5.github.io/north-dakota-eats.
- **Screenshots:**
  1. `scripts/capture-screenshots.sh <sim>`. ScreenshotMode pins downtown Fargo by default, south Fargo for knoephla and the Kroll's
     Diner detail, and Grand Forks for steaks.
  2. `scripts/site-images.sh`, then make-site and qa-site.
  3. App Store frames: `scripts/appstore-screenshots.py`.
- **Listing:** `playbook/app-store/listing.json`.

## Status
See the end of this file (written when the build finished).

### Status (2026-11-07 05:10)
- **Ready to publish; nothing public.** No repo, commit, push, Pages, App Store Connect record or build upload; all of those wait for
  Nick's yes.
- Data: 1,736 restaurants (1,837 places) in 248 towns, 53 counties; 11 hand-checked guide places (6 knoephla and kuchen, 5 steaks and
  walleye); 1 James Beard honoree (Luna Fargo's restaurateurs, 2025 Outstanding Restaurateur semifinalists). No official list is read: NDHHS's and the local units'
  inspections are search-only (each place links NDHHS's food and lodging page; no result, no grade), and the Attorney General's
  licensee list is a PDF mixing on- and off-sale, so "Serves alcohol" is "—" everywhere.
- Late fixes (2026-11-06/07), all leftovers of the port from Iowa: `isOutsideNorth Dakota` (a compile error) and escaped triple quotes
  in the test fixtures; the web app's `const inNorth Dakota` (a syntax error that broke the search page) and its map framed on Iowa;
  "Fargo, IA" in town-page leads and `addressRegion "IA"` in the structured data; "Surprise me with an North Dakota classic"; the UI
  tests' Iowa searches ("bettendorf", "Archie's Waeside"); website-count floors and one-place-guide headers in the tests.
- Tests (Xcode 1.app 27.2, iOS 27.0), final runs 2026-11-07: iPhone 17 Pro Max 49 unit + 6 UI tests passed; iPad 13" (M5) 49 unit + 6
  UI tests passed (the launch-time test skipped itself under load).
- Site: `docs/` generated; `qa-site.py --static` and the full headless-Chrome run both OK (2026-11-07 02:35); `publish_app_data.py
  --check` OK.
- App Store: 6 iPhone and 4 iPad frames in `playbook/app-store/` (the iPad set retaken on a fresh portrait boot, the home shot twice so
  its map tiles load); `listing.json` (North Dakota Eats: Restaurants; Knoephla, Steaks & Walleye; support and privacy on
  nickstrom5.github.io/north-dakota-eats/).
- Brand final (Nick, 2026-11-07): "North Dakota Eats" (Home Screen "ND Eats"), the knoephla icon and the palette, as built. Nick
  said yes to scripting the NDHHS FIMS search export.
