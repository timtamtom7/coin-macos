# Coin — Onboarding Screens

Coin's user is crypto-fluent. They don't need to be sold on portfolio tracking — they need to be shown that Coin is the native, fast, beautiful option they've been waiting for. 4 screens that lead with the aesthetic and speed, then show how easy setup is.

---

## Screen 1 — Welcome / Portfolio Overview

**Trigger:** First launch

**Layout:** Full-bleed illustration — no chrome, no nav. Just the product shown as art.

**Illustration concept:**
A dark (`#0D1117`) full-width illustration showing the Coin main window in a cinematic, partially cropped view. The portfolio area is at the top: a large area chart (the `#58A6FF` line + gradient fill) spanning the full width of the window mockup. Below the chart, three portfolio rows are visible: BTC, ETH, and SOL — each with a coin icon, name, holdings amount, price, and small sparkline. A gold `#F0B429` price alert badge blinks on one of the rows.

The window is shown at an angle (2D isometric-ish tilt, 4deg) to feel more like an editorial product shot than a flat screenshot.

**Visual style:**
- Window mockup: `#161B22` background, `#30363D` border, 12pt corner radius
- Chart line: `#58A6FF`, 2pt stroke
- Chart fill: `#58A6FF` to transparent gradient (30% → 0% opacity), from line down to x-axis
- Sparklines: `#58A6FF`, 1pt stroke, no fill
- Bull/green numbers: `#3FB950`
- Bear/red numbers: `#F85149`
- Gold alert badge: `#F0B429`, 6pt circle with a small "!" inside
- Background: `#0D1117` — the whole screen is the dark canvas

**Text (minimal, bottom of screen):**
> "Your portfolio, native on Mac."
> "Real-time prices. Price alerts. No browser tab."

**CTA:** "Add Your First Asset →" — `#F0B429` fill (gold), white text, 40pt height, 8pt corner radius.

---

## Screen 2 — Add Assets / Search

**Trigger:** First time using the "Add Asset" flow

**Layout:** Centered search panel with results list below.

**Illustration concept:**
The Add Asset sheet is shown as a floating modal over a blurred dark background. The modal has:
- A search field at the top: dark `#0D1117` fill, `#30363D` border, white placeholder text "Search Bitcoin, Ethereum..."
- Three search result rows below:
  1. BTC — Bitcoin — shown with a small orange circle icon, price, and market cap
  2. ETH — Ethereum — green circle icon, price, market cap
  3. ETH2 — Ethereum 2 — same green circle icon with a small "2" badge
- A "Selected" state on BTC with a gold `#F0B429` left border and a `plus.circle.fill` icon on the right

A small hint text at the bottom of the modal: "Search by name, symbol, or contract address."

**Visual style:**
- Modal: `#1C2128` fill, `#30363D` border, 12pt corner radius, 400pt wide
- Search field: `#0D1117` fill, `#30363D` border (focused: `#F0B429`), 36pt height, 8pt corner radius
- Result rows: `#161B22` fill on hover, `#1C2128` default, 48pt height
- Asset icons: 20pt circles with asset symbol initials, colored by asset
- Selected state: `#F0B429` left border (3pt), `#30363D` border, `#0F172A` background

**Text:**
> "Search 10,000+ coins and tokens."
> "Paste a contract address to track any ERC-20 or SPL token."

---

## Screen 3 — Set a Price Alert

**Trigger:** First time setting an alert (prompted after first asset is added, or shown as Screen 3)

**Layout:** A compact alert creation form shown as an inline sheet.

**Illustration concept:**
The alert setup sheet slides up from the bottom of the main window mockup. It shows a preview of the BTC price row at the top (coin icon, name, current price $67,432.10, sparkline). Below, the alert configuration form:

- Two large toggle/button options side by side: "Above" (green `#3FB950` border, white text) and "Below" (red `#F85149` border, white text) — "Above" is selected
- A price input field: `$ 70,000` (pre-filled suggestion), with a small label "Alert when BTC rises above"
- A frequency selector: three small pill buttons — "Once", "Every time", "Daily digest" — "Once" is selected
- A preview line showing "🔔 BTC above $70,000 → Telegram notification" in a small callout box

**Visual style:**
- Sheet: `#161B22` fill, `#30363D` top border, 12pt top corner radius
- Toggle buttons: `#0D1117` fill, `#30363D` border when unselected; colored border when selected (green/red)
- Input field: `#0D1117` fill, `#30363D` border, white text in SF Mono
- Callout preview: `#1C2128` fill, `#30363D` border, 6pt corner radius, small bell icon `#D29922`

**Text:**
> "Get notified when Bitcoin hits your target."
> "Alerts work even when Coin is closed."

---

## Screen 4 — Portfolio History

**Trigger:** First time viewing the portfolio history chart

**Layout:** Full portfolio chart shown as the hero, with time range controls above and a data table below.

**Illustration concept:**
A large portfolio chart fills most of the screen — the `#58A6FF` area chart dominates. Above the chart, five time range pills are shown: 1H, 24H, 7D, 30D, 1Y — "7D" is selected (gold `#F0B429` fill). A floating tooltip is shown at a point on the chart: a small dark card with "Nov 14 — $42,310.00" and a small green arrow up and "+$1,240 (+3.0%)" in `#3FB950`.

Below the chart, a compact holdings breakdown table is shown: Asset | Holdings | Price | 24h % | 7d % — with alternating `#161B22` and `#1C2128` row backgrounds.

**Visual style:**
- Chart area: `#58A6FF` gradient fill (30% → 0%), `#58A6FF` line 2pt
- Grid: horizontal lines only, `#30363D` at 40% opacity
- Time range pills: `#0D1117` fill, `#30363D` border when unselected; `#F0B429` fill when selected
- Tooltip card: `#1C2128` fill, `#30363D` border, 6pt radius, soft shadow
- Table rows: alternating `#161B22` / `#1C2128`
- Percentage change badges: green `#3FB950` text with small arrow up for gains, red for losses

**Text:**
> "Track your portfolio over time."
> "See total value, daily change, and per-asset performance — all in one chart."

**CTA:** "Track More Assets →" — gold outline `#F0B429`, 36pt height, 8pt corner radius.
