<p align="center">
  <img width="120" src="./Designs/MaccyBlue.png" alt="Maccy Blue" />
  <h1 align="center">Maccy Blue</h1>
  <p align="center"><strong>Fast, lightweight, native macOS clipboard manager.</strong></p>
  <p align="center">
    <img src="https://img.shields.io/badge/macOS-14.0%2B-007AFF?logo=apple&logoColor=white" alt="macOS 14+" />
    <img src="https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white" alt="Swift 6.0" />
    <img src="https://img.shields.io/badge/Architecture-Universal-black" alt="Universal" />
    <img src="https://img.shields.io/badge/RAM-Optimized-00A86B" alt="RAM Optimized" />
    <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License MIT" />
    <a href="https://github.com/p0deje/Maccy"><img src="https://img.shields.io/badge/Fork%20of-p0deje%2FMaccy-8A2BE2" alt="Fork of Maccy" /></a>
  </p>
</p>

<p align="center">
  <img src="./Designs/MaccyBlue-Preview.png" width="680" alt="Maccy Blue Interface Preview" />
</p>

## Overview

**Maccy Blue** is an optimized fork of [Maccy](https://maccy.app) focused on bulletproof clipboard image compatibility, zero-allocation memory management, and clean modern aesthetics.

---

## Improvements & Technical Benefits

### 1. Dual-Representation Image Synthesis (`public.png` + `public.tiff`)
- **Problem**: Upstream Maccy only restored whichever single format was captured. If an image only had TIFF, Chromium/Electron apps (Slack, Discord, VS Code, Notion) failed to paste. If it only had PNG, Apple native Cocoa apps (Pages, Keynote, Preview) rejected it.
- **Benefit**: Universal pasting compatibility. Maccy Blue generates both `public.png` and `public.tiff` representations simultaneously on the pasteboard when restoring image history items.

### 2. Multi-Type Format Stripping
- **Problem**: Web browsers copy images with accompanying text metadata (alt text, source URL). Upstream Maccy's `clearFormatting()` dropped image binaries if text was present.
- **Benefit**: Retains image payloads when using "Paste without formatting" on web-copied clips.

### 3. Zero-Allocation Type Checks (`hasImageContent`)
- **Problem**: Upstream checked `hasImage` via `item.image != nil`. This allocated and decoded a full `NSImage` bitmap into RAM for every item during list rendering, search filtering, and scrolling.
- **Benefit**: Zero bitmap decompression during search and scroll. Only checks lightweight pasteboard string identifiers (`public.png`, etc.).

### 4. Header-Only Metadata Extraction (`CGImageSource`)
- **Problem**: Querying image dimensions in upstream required instantiating the full bitmap in memory.
- **Benefit**: Reads image width and height directly from file headers via ImageIO (`CGImageSourceCopyPropertiesAtIndex`) in microseconds with zero pixel buffer allocation.

### 5. Resilient Database Engine & Fault Recovery
- **Problem**: Upstream Maccy crashed with unrecoverable `fatalError` whenever SQLite schema or store loading failed.
- **Benefit**: Automatic database fault recovery. Detects store issues on startup, backs up the database safely, and reinitializes with zero user-facing crash.

### 6. Popup Dismissal RAM Eviction (`cleanupImages()`)
- **Problem**: Decoded thumbnail bitmaps accumulated in memory and lingered indefinitely after the menu was closed.
- **Benefit**: Closes popup $\rightarrow$ immediately flushes all decoded thumbnail buffers from memory. RAM returns to baseline (~30–50MB).

### 7. Unified Feather Iconography
- **Problem**: Upstream had disconnected branding (lightbulb app icon vs. feather menu bar icon) and a legacy `AppIcon.icon` bundle that overrode custom iconsets in Release builds.
- **Benefit**: Purged conflicting Icon Composer bundle. Unified menu bar, Dock, Cmd+Tab switcher, and Finder around the feather emblem on royal blue across all 10 macOS resolutions (16px to 1024px).

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

## Build & Install

### Requirements
- macOS 14.0 (Sonoma) or higher
- Xcode 16+ / Swift 6.0

### Build from Source
```sh
git clone https://github.com/sanad-source/Maccy-Blue.git
cd Maccy-Blue
xcodebuild -scheme Maccy -configuration Release clean build
```

---

## License

[MIT](./LICENSE)
