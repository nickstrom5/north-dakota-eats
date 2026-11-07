# North Dakota sources and calibration (checked 2026-11-06)

## Official sources
| Source | What it has | Can a script read it? | Used |
|---|---|---|---|
| NDHHS FIMS (fims.doh.nd.gov/Web/Inspection/PublicInspectionSearch.aspx) | inspections by NDHHS and five local units (Central Valley, Grand Forks, Southwestern, Upper Missouri, Western Plains): dates, violation counts, the two latest reports | search-only; its Export gives a CSV per query, with no address and an empty score | no; a records request (NDCC 44-04-18) is Nick's call |
| First District Health Unit (inspections.myhealthdepartment.com/firstdistrict) | an official 0–100 score | no: 403 to scripts (browser only) | no |
| Fargo Cass (fargo-nd.healthinspections.us/fargo) and Bismarck (eTRAKiT) | inspections, last inspection date, no score | search-only | no |
| NDHHS Food and Lodging (hhs.nd.gov/health/food-and-lodging) | who inspects where | page | linked from every place |
| Attorney General "Retail Alcoholic Beverage Licensees" PDF (attorneygeneral.nd.gov/licensing-and-gaming/license-holders/) | 1,614 licenses (on- and off-sale mixed), licensee legal names (often people) | a PDF | no: it proves a license to sell, not that a place serves; never show the licensee names |
| NDGISHUB parcels | building values | yes | no: its terms are a disclaimer with no redistribution grant (ask Nick first) |

- Places on tribal lands, casinos included, are under tribal jurisdiction. The app says so for every place, and never says "no
  violations".
- Nothing is calibrated against an official list. The keep rule is the family's: Meta 0.95, or 0.90 with a website. No Google data is
  read anywhere.

## Counts
- App: 1,837 places, 1,736 restaurants in 248 towns (Census CBP 2023: 1,815 NAICS 722 establishments).
- Web: 2,597 places.
- Overture: 3,894 eating and drinking listings, 193 of them marked closed.
- Casey's and the grocery counters (Hornbacher's, Cash Wise, Hugo's) are hidden with the non-restaurants. Whether they appear is
  Nick's call.

## Research hosts (check_sources.py)
- **Usable:** fargomoorhead.org, visitgrandforks.com, devilslakend.com, medora.com, discoverbismarckmandan.com, ndliving.com,
  prairiepublic.org, minotdailynews.com, wday.com, northdakotamonthly.com, ndhumanities.org, tastingtable.com, us1033.com,
  965thewalleye.com, jamesbeard.org.
- **Blocked by robots.txt:** inforum.com, grandforksherald.com, jamestownsun.com, thedickinsonpress.com, willistonherald.com,
  kfyrtv.com, valleynewslive.com, kxnet.com, kvrr.com, visitminot.org.
- **Other:**
  - ndtourism.com answers with a bot check.
  - bismarcktribune.com passes robots.txt but sends bots to a paid gateway (TollBit), so it isn't cited.
  - The Fargo-Moorhead visitor bureau's listing pages draw their text in the browser. Each listing's own fields sit in the page's
    embedded data, read by script.
