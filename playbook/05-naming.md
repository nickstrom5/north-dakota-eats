# North Dakota Eats: name, icon and palette

**Final: Nick's decision of 2026-11-07 ("Yes, as proposed" on the 17-state review page).**
Name, icon A (knoephla) and palette exactly as built.

## Name
- **North Dakota Eats**:
  - App Store name "North Dakota Eats: Restaurants" (30 characters, the limit).
  - Subtitle "Knoephla, Steaks & Walleye" (26).
  - Home Screen name "ND Eats", as the prompt suggests: "North Dakota Eats" is cut off under the icon.
- Why, per the prompt: it has the best search fit, and no App Store app has the name. northdakotaeats.com is registered but shows an
  expired Squarespace page.
- Alternatives:
  - "Dakota Eats": the .com is unregistered, but it reads as South Dakota too.
  - "Peace Garden Eats": the state nickname, and the .com is unregistered; check the International Peace Garden's marks first.
- Avoided:
  - "Be Legendary." (the state brand line; check TSDR).
  - UND/Fighting Hawks, the retired Fighting Sioux name, NDSU/Bison.
  - "Roughrider" (the state's Rough Rider Award and a CFL team).

## Icon (state-prompts/ICON-STYLE.md; all three pass state-prompts/icon-style/check.swift)
- **A, chosen (final): a bowl of knoephla**, side elevation, with potato dumplings over the broth line. It reads as a bowl of
  dumpling soup at 60 px and matches the Knoephla & Kuchen guide.
- B: a fleischkuechle, the golden half-moon of fried dough. At 60 px it could be a taco or an empanada.
- C: a slice of rhubarb pie with a lattice top. It reads as pie, but not as North Dakota's.
- No bison or hawks (NDSU, UND), no flag eagle, no great seal (NDCC 54-02-01).
- `scripts/icon-concepts.swift` draws all three. `scripts/make-brand.swift` makes the app icon, favicons, touch icons and og.png from
  A.

## Palette (the landscape: fans split between NDSU's green and gold and UND's green)
| Role | Hex | Contrast |
|---|---|---|
| Titles, tint, honors and oldest cards, icon background | big-sky blue #1E4F8C | 8.2:1 on white |
| Hand-checked guide cards, chips | Badlands scoria red #A63D2A | white on it 6.3:1 |
| Pins, the title shadow, the header's ground (fill only) | sunflower gold #E8B83A | #1A1A1A on it 9.9:1; never text on white |
| Pages | cream #F7F2E6 | |

## Header
One element: a prairie horizon with a grain elevator. It appears as Theme.swift's Stripes, make-site.py's RAYS and the band on og.png.
