<p align="center">
  <img width="120" src="./Designs/MaccyBlue.png" alt="Maccy Blue Logo - Lightweight macOS Clipboard Manager" />
  <h1 align="center">Maccy Blue</h1>
  <p align="center"><strong>Fast, lightweight, native macOS clipboard history manager built with Swift & SwiftUI.</strong></p>
  <p align="center">
    <img src="https://img.shields.io/badge/macOS-14.0%2B%20(Sonoma%20%7C%20Sequoia)-007AFF?logo=apple&logoColor=white" alt="macOS 14+ (Sonoma & Sequoia)" />
    <img src="https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white" alt="Swift 6.0" />
    <img src="https://img.shields.io/badge/Architecture-Universal%20(Apple%20Silicon%20%26%20Intel)-black?logo=apple" alt="Universal Apple Silicon & Intel" />
    <img src="https://img.shields.io/badge/RAM-Optimized%20(~30--50MB)-00A86B" alt="RAM Optimized (~30-50MB)" />
    <img src="https://img.shields.io/badge/Privacy-100%25%20Offline%20%2F%20Zero%20Telemetry-success" alt="100% Offline / Zero Telemetry" />
    <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License MIT" />
  </p>
</p>

<p align="center">
  <img src="./Designs/MaccyBlue-Preview.png" width="680" alt="Maccy Blue Interface Preview - Fast macOS Clipboard History Menu Bar Utility" />
</p>

## Overview

**Maccy Blue** is an open-source, high-performance clipboard history manager for macOS Sonoma (14.0+) and macOS Sequoia (15.0+). Designed for Apple Silicon (M1/M2/M3/M4) and Intel architectures, it provides an ultra-fast, keyboard-driven menu bar utility that records clipboard history, fixes cross-application image pasting bugs, and maintains an ultra-lean memory profile.

Unlike bloated clipboard tools that consume hundreds of megabytes of RAM or send clipboard contents to cloud servers, Maccy Blue is **100% offline, privacy-first, and zero-telemetry**, storing all history locally in an encrypted macOS Core Data / SQLite store.

---

## Comparison: Maccy Blue vs. Standard Clipboard Managers

| Feature | Standard Maccy | Maccy Blue | Technical Benefit |
|:---|:---:|:---:|:---|
| **Chromium & Electron Image Pasting** | ❌ Fails (TIFF only) | ✅ **Dual PNG + TIFF Synthesis** | Reliable image pasting into Slack, Discord, VS Code, Notion, Chrome |
| **Native Cocoa Image Pasting** | ⚠️ Partial (if PNG only) | ✅ **Universal Dual Representation** | Flawless pasting into Apple Pages, Keynote, Preview, Mail |
| **Search & Scroll RAM Allocation** | ⚠️ Instantiates full `NSImage` | ✅ **Zero-Allocation String IDs** | Zero bitmap decode lag while typing or browsing history |
| **RAM Eviction on Dismiss** | ❌ Retains bitmaps in RAM | ✅ **Instant Buffer Flushing** | Memory drops back to ~30–50MB baseline immediately on menu close |
| **Image Dimension Querying** | ⚠️ Loads full uncompressed bitmap | ✅ **Header-Only `CGImageSource`** | Metadata read directly from header bytes in microseconds |
| **Database Corruption Recovery** | ❌ Unrecoverable `fatalError` | ✅ **Automatic Fault Recovery** | Detects corrupted stores, backs up safely, and recovers seamlessly |
| **Interface & Dropdown Height** | ⚠️ Tall list, 4 bottom buttons | ✅ **Compact, Distraction-Free** | Half-height dropdown with quick clear icon and trackpad secondary menu |
| **Scrollbar Appearance** | ⚠️ Persistent overlay scrollbars | ✅ **Clean Hidden Indicators** | Clean minimalist aesthetic matching modern macOS design |
| **Telemetry & Privacy** | ✅ Local storage | ✅ **100% Offline & Private** | Zero network calls, zero tracking, local SQLite storage |

---

## Technical Improvements & Benefits

### 1. Dual-Representation Image Synthesis (`public.png` + `public.tiff`)
> [!WARNING]
> **Problem:** Standard clipboard managers only restore whichever single image representation was captured at copy time. If an image only contained TIFF data, Chromium and Electron applications (Slack, Discord, VS Code, Notion, Chrome) failed to recognize and paste it. If it only contained PNG data, native Apple Cocoa applications (Pages, Keynote, Preview) rejected it.

> [!TIP]
> **Solution & Benefit:** Universal pasting compatibility across all macOS software. Maccy Blue generates both `public.png` and `public.tiff` representations simultaneously on the system pasteboard whenever an image history item is restored.

### 2. Multi-Type Format Stripping
> [!WARNING]
> **Problem:** Web browsers routinely copy images with accompanying text metadata (alt text, captions, or source URLs). Standard "paste without formatting" routines discarded image binaries whenever string metadata was present.

> [!TIP]
> **Solution & Benefit:** Retains pure image payloads when using "Paste without formatting" (`⌥⇧Enter`) on web-copied clips.

### 3. Zero-Allocation Type Checks (`hasImageContent`)
> [!WARNING]
> **Problem:** Standard implementations verified image presence via `item.image != nil`. This allocated and decoded a full `NSImage` bitmap into RAM for every clip during list rendering, search filtering, and scrolling.

> [!TIP]
> **Solution & Benefit:** Zero bitmap decompression during search and scrolling. Maccy Blue evaluates lightweight pasteboard UTI identifiers (`public.png`, `public.tiff`) without touching image payloads.

### 4. Header-Only Metadata Extraction (`CGImageSource`)
> [!WARNING]
> **Problem:** Querying image dimensions required instantiating the complete uncompressed bitmap in application memory.

> [!TIP]
> **Solution & Benefit:** Reads image width and height directly from file header bytes via ImageIO (`CGImageSourceCopyPropertiesAtIndex`) in microseconds with zero pixel buffer allocation.

### 5. Resilient Database Engine & Fault Recovery
> [!WARNING]
> **Problem:** SQLite schema mismatches or corrupted storage caused unrecoverable application crashes on launch.

> [!TIP]
> **Solution & Benefit:** Automatic database fault recovery. Detects store issues on startup, backs up the existing database safely, and reinitializes with zero user-facing crash.

### 6. Popup Dismissal RAM Eviction (`cleanupImages()`)
> [!WARNING]
> **Problem:** Decoded thumbnail bitmaps accumulated in memory and lingered indefinitely after the clipboard popup was closed.

> [!TIP]
> **Solution & Benefit:** Closes popup $\rightarrow$ immediately flushes all decoded thumbnail buffers from memory. RAM returns to baseline (~30–50MB).

### 7. Unified Feather Iconography
> [!WARNING]
> **Problem:** Disconnected branding and legacy icon bundles caused visual inconsistencies across macOS resolutions and release builds.

> [!TIP]
> **Solution & Benefit:** Unified menu bar, Dock, Cmd+Tab switcher, and Finder around the royal blue feather emblem across all 10 native macOS resolutions (16px to 1024px).

### 8. Focused Trackpad & Menu Bar Quick Actions
> [!WARNING]
> **Problem:** Settings and application controls crowded the bottom of the dropdown with 4 persistent buttons, taking up vertical space for clipboard items.

> [!TIP]
> **Solution & Benefit:** Clean, distraction-free dropdown. Double-clicking or two-finger trackpad clicking anywhere on the panel or menu bar icon presents a clean 3-item menu (Preferences, About, Quit). An instant one-click trash icon is placed beside the search bar.

---

## Keyboard Shortcuts

| Shortcut | Action |
|:---|:---|
| <kbd>⇧</kbd> + <kbd>⌘</kbd> + <kbd>C</kbd> | Toggle Maccy Blue popup |
| <kbd>Enter</kbd> / Click | Copy item to clipboard |
| <kbd>⌥</kbd> + <kbd>Enter</kbd> / <kbd>⌥</kbd> + Click | Paste item immediately |
| <kbd>⌥</kbd> + <kbd>⇧</kbd> + <kbd>Enter</kbd> | Paste item without formatting |
| <kbd>⌥</kbd> + <kbd>P</kbd> | Pin / unpin item to top |
| <kbd>⌥</kbd> + <kbd>⌫</kbd> | Delete selected item |
| <kbd>⌥</kbd> + <kbd>⌘</kbd> + <kbd>⌫</kbd> | Clear unpinned history |
| <kbd>⌘</kbd> + <kbd>,</kbd> | Preferences |

---

## Frequently Asked Questions (FAQ)

### What makes Maccy Blue different from standard Maccy?
Maccy Blue is an optimized fork engineered specifically for modern macOS development workflows. It solves clipboard image pasting failures in Chromium and Electron applications (Slack, VS Code, Discord, Notion), optimizes memory consumption by evicting decoded thumbnails on menu dismissal, reduces dropdown height, removes cluttered footer buttons in favor of gesture controls, and hardens SQLite database recovery.

### Why do copied images fail to paste in Slack, Discord, or Notion?
macOS pasteboard items can contain multiple data representations. Chromium and Electron apps look strictly for `public.png` payloads. Standard clipboard tools frequently capture or write only `public.tiff`. Maccy Blue synthesizes both `public.png` and `public.tiff` simultaneously upon pasteboard restoration, guaranteeing compatibility across all apps.

### How does Maccy Blue keep RAM usage low?
Maccy Blue avoids loading bitmap data during search and list traversal by checking UTI type identifiers. When the popup is closed, Maccy Blue triggers an aggressive cache flush (`cleanupImages()`) that releases decoded image buffers, returning RAM to a lightweight baseline of ~30–50MB.

### How do I open Preferences or Quit without bottom buttons?
Maccy Blue streamlines the interface by moving secondary controls to intuitive shortcuts and gestures:
- Press <kbd>⌘</kbd> + <kbd>,</kbd> while the popup is open to enter **Preferences**.
- Two-finger tap (or right-click) the menu bar icon or dropdown panel to open the **Quick Action Menu** (Preferences, About, Quit).
- Click the trash icon beside the search bar to clear unpinned history.

### Is Maccy Blue private and secure?
Yes. Maccy Blue operates 100% locally on your machine. It makes zero network requests, contains zero analytics or telemetry tracking, and stores clipboard history entirely within your local macOS Application Support directory.

---

## Build & Install

### Requirements
- macOS 14.0 (Sonoma) or macOS 15.0 (Sequoia)+
- Apple Silicon (M1/M2/M3/M4) or Intel 64-bit CPU
- Xcode 16+ / Swift 6.0

### Build from Source
```sh
git clone https://github.com/sanad-source/Maccy-Blue.git
cd Maccy-Blue
xcodebuild -scheme Maccy -configuration Release clean build
```

---

## License

Distributed under the [MIT License](./LICENSE).
