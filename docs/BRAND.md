# Coin — Brand Guide

## App Overview

Coin is a cryptocurrency portfolio tracker for macOS. It monitors holdings across exchanges and wallets, displays real-time prices, tracks portfolio history, and alerts on price movements. Designed for the crypto-native user who wants a clean, native macOS experience — not a web app crammed into a frame.

---

## Icon Concept

**Primary icon:** A single coin (circle) with a subtle inner ring and a light shine/highlight on the upper-left quadrant — classic coin iconography. The coin has a slight 3D depth (a very subtle inner shadow and a highlight arc) without being skeuomorphic. A small upward sparkline or chart arc is etched into the coin's face.

**Alternative compositions:**
- Two overlapping coins at slight angles (suggesting a stack or portfolio)
- A coin with a small "₿" or similar crypto symbol subtly embossed

**Design principles:** The coin should feel premium and liquid — this is about value, trust, and growth. Not playful, not aggressive. The upward chart element within the coin communicates "portfolio going up" without needing a green arrow. All variants work on light and dark backgrounds.

**Do NOT:** Use green Bitcoin logos, dog coins, or meme coin imagery. Keep it generic enough to represent any crypto without endorsing a specific chain.

---

## Color Palette

| Role | Name | Hex | Usage |
|------|------|-----|-------|
| Background | Deep Navy | `#0D1117` | Main window background — dark theme native |
| Background Alt | Surface | `#161B22` | Cards, panels in dark mode |
| Surface | Card Dark | `#1C2128` | Elevated cards, modals |
| Border | Subtle | `#30363D` | Card outlines, dividers |
| Text Primary | White | `#F0F6FC` | Headings, prices, primary labels |
| Text Secondary | Muted | `#8B949E` | Paths, timestamps, secondary info |
| Accent | Gold | `#F0B429` | Primary CTAs, the Coin brand color |
| Gain / Up | Bull Green | `#3FB950` | Positive price changes, gains |
| Loss / Down | Bear Red | `#F85149` | Negative price changes, losses |
| Chart Line | Electric Blue | `#58A6FF` | Portfolio chart line, sparklines |
| Alert | Amber | `#D29922` | Price alerts, warnings |

> **Note:** Coin is a dark-theme-first app (`#0D1117` background). All brand colors are calibrated to work on dark backgrounds. If a light mode is supported, all text and border colors must be inverted/recalculated — do not assume colors are universal. The gold accent (`#F0B429`) is the single brand color; use it for branding elements only. Price direction (up/down) always uses green (`#3FB950`) or red (`#F85149`).

---

## Typography

**Font family:** SF Pro (system font)

| Element | Weight | Size |
|---------|--------|------|
| Price (large) | Bold | 22pt, SF Mono |
| Price (list row) | Medium | 13pt, SF Mono |
| Asset Name | Semibold | 13pt |
| Holdings / Amount | Medium | 12pt |
| Section Header | Medium | 11pt, uppercase, letter-spaced 0.06em |
| Caption / % Change | Regular | 11pt |
| Timestamp | Regular | 10pt |

**Guidelines:**
- All monetary values always in `SF Mono` — critical for digit alignment and financial data readability
- Percentage changes shown with a `+` or `-` prefix and colored green/red
- Use tabular numbers (`font-variant-numeric: tabular-nums`) via SF Pro's built-in tabular figures
- No custom fonts

---

## Visual Motif

**Core motif: The coin, the chart, and the spark.**
The visual language combines financial data precision with the elegance of a premium portfolio tool. Clean lines, generous whitespace, and a dark canvas that lets the data (prices, charts) be the visual focus.

**Key visual elements:**
- **Sparkline:** A thin, single-line chart without axes — just the line going up or down, used in list rows to show 7-day trend at a glance. Colored `#58A6FF` (blue) by default, or green/red for directional context.
- **Portfolio chart:** A full area chart (gradient fill from `#58A6FF` at 30% to transparent) with a single `#58A6FF` line. The chart area has a subtle grid (horizontal lines only, `#30363D` at 50% opacity). A floating tooltip shows the value at the hovered point.
- **Price tickers:** Shown with large bold numbers in SF Mono, right-aligned with the asset symbol (e.g., "BTC $67,432.10"). The percentage change in a small pill badge — green background for gain, red for loss.
- **Coin icons:** Each asset gets a small 20pt circular icon with the asset's symbol or logo. These are fetched from a reliable icon API (CoinGecko or similar) and cached locally.
- **Alert badges:** Small amber `#D29922` dots appear next to assets that have an active price alert.

**Icon library:** SF Symbols supplemented by crypto asset icons (fetched/cached). Key SF Symbols: `chart.line.uptrend.xyaxis`, `arrow.up.right`, `arrow.down.right`, `bell`, `bell.fill`, `plus.circle`, `gearshape`.

**Patterns:** No decorative patterns. The subtle horizontal grid in the chart is the only repeating element, and it's purely functional.

---

## Size Behavior

| Context | Width | Height | Notes |
|---------|-------|--------|-------|
| Menu bar popover | 360pt | 440pt | Quick portfolio overview + alerts |
| Main window | 560pt | 480pt | Full portfolio, chart, history |
| Asset list row | Full width | 56pt | Single asset row with sparkline |
| Portfolio chart | Full width | 200pt | Area chart at top of main window |
| Alert setup panel | 320pt | auto | Sheet/modal for creating alerts |
| Settings window | 440pt | 360pt | Exchange connections, preferences |

**Adaptive:** The main window is resizable (min 480×360pt). The asset list scrolls vertically. The chart maintains its aspect ratio and scales horizontally.
