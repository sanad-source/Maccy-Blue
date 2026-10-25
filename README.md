> [!WARNING]
> **Beware of fake websites impersonating Maccy.** Malicious sites (such as `maccyapp.net` and `maccyapp.com`) distribute malware disguised as Maccy. [**maccy.app**](https://maccy.app) is the **only** official website.

<p align="center">
  <img width="128px" src="./Designs/MaccyBlue.png" alt="Maccy Blue Logo" />
</p>

# Maccy Blue

Maccy Blue is a high-performance, optimized fork of [Maccy](https://maccy.app) for macOS (Sonoma 14+). It introduces critical clipboard image compatibility fixes, aggressive memory optimizations under heavy image workloads, and a refreshed visual identity featuring the iconic menu bar feather emblem.

<!-- vim-markdown-toc GFM -->

* [Improvements in Maccy Blue](#improvements-in-maccy-blue)
  * [1. Universal Image Pasting](#1-universal-image-pasting)
  * [2. Aggressive Memory & RAM Optimization](#2-aggressive-memory--ram-optimization)
  * [3. Feather Emblem App Icon & Blue Branding](#3-feather-emblem-app-icon--blue-branding)
* [Features](#features)
* [Install](#install)
* [Usage](#usage)
* [Advanced](#advanced)
  * [Ignore Copied Items](#ignore-copied-items)
  * [Ignore Custom Copy Types](#ignore-custom-copy-types)
  * [Speed up Clipboard Check Interval](#speed-up-clipboard-check-interval)
* [FAQ](#faq)
* [License](#license)

<!-- vim-markdown-toc -->

## Improvements in Maccy Blue

### 1. Universal Image Pasting
* **Dual-Representation Image Synthesis**: When pasting previously copied images, Maccy Blue synthesizes both `public.png` and `public.tiff` pasteboard representations. This resolves pasting failures across Apple native apps (Pages, Keynote, Notes) and Electron/Chromium apps (Slack, Discord, VS Code, Chrome).
* **Multi-type Preservation**: Items copied from web browsers that bundle OCR/alt-text alongside image data retain their image payloads during formatting strip operations rather than dropping the image binary.

### 2. Aggressive Memory & RAM Optimization
* **Zero-Allocation Type Inspection**: Replaced eager `item.image != nil` checks during list decoration with `item.hasImageContent`, eliminating upfront bitmap decoding during search and scroll.
* **Header-Only Metadata Extraction**: Image dimensions are parsed directly from ImageIO headers (`CGImageSourceCopyPropertiesAtIndex`) without allocating decoded pixel buffers.
* **External Binary Offloading**: Stored image payloads use SwiftData `@Attribute(.externalStorage)`, keeping large binary blobs out of SQLite row caches.
* **RAM Eviction on Popup Close**: Hooked popup dismissal (`reset()`) to call `History.shared.cleanupImages()`, aggressively freeing cached bitmap memory when the clipboard menu closes.

### 3. Feather Emblem App Icon & Blue Branding
* **Icon Modernization**: Replaced the legacy lightbulb icon with the menu bar feather/quill emblem on an Apple royal blue squircle across all 10 resolutions (16px to 1024px).
* **Maccy Blue Status Bar Theme**: Added `.maccyBlue` status bar emblem with original template rendering support.


## Features

* Lightweight and fast
* Keyboard-first
* Secure and private
* Native UI
* Open source and free

## Install

Download the latest version from the [releases](https://github.com/p0deje/Maccy/releases/latest) page, or use [Homebrew](https://brew.sh/):

```sh
brew install maccy
```

## Usage

1. <kbd>SHIFT (⇧)</kbd> + <kbd>COMMAND (⌘)</kbd> + <kbd>C</kbd> to popup Maccy or click on its icon in the menu bar.
2. Type what you want to find.
3. To select the history item you wish to copy, press <kbd>ENTER</kbd>, or click the item, or use <kbd>COMMAND (⌘)</kbd> + `n` shortcut.
4. To choose the history item and paste, press <kbd>OPTION (⌥)</kbd> + <kbd>ENTER</kbd>, or <kbd>OPTION (⌥)</kbd> + <kbd>CLICK</kbd> the item, or use <kbd>OPTION (⌥)</kbd> + `n` shortcut.
5. To choose the history item and paste without formatting, press <kbd>OPTION (⌥)</kbd> + <kbd>SHIFT (⇧)</kbd> + <kbd>ENTER</kbd>, or <kbd>OPTION (⌥)</kbd> + <kbd>SHIFT (⇧)</kbd> + <kbd>CLICK</kbd> the item, or use <kbd>OPTION (⌥)</kbd> + <kbd>SHIFT (⇧)</kbd> + `n` shortcut.
6. To delete the history item, press <kbd>OPTION (⌥)</kbd> + <kbd>DELETE (⌫)</kbd>.
7. To see the full text of the history item, wait a couple of seconds for tooltip.
8. To pin the history item so that it remains on top of the list, press <kbd>OPTION (⌥)</kbd> + <kbd>P</kbd>. The item will be moved to the top with a random but permanent keyboard shortcut. To unpin it, press <kbd>OPTION (⌥)</kbd> + <kbd>P</kbd> again.
9. To clear all unpinned items, select _Clear_ in the menu, or press <kbd>OPTION (⌥)</kbd> + <kbd>COMMAND (⌘)</kbd> + <kbd>DELETE (⌫)</kbd>. To clear all items including pinned, select _Clear_ in the menu with  <kbd>OPTION (⌥)</kbd> pressed, or press <kbd>SHIFT (⇧)</kbd> + <kbd>OPTION (⌥)</kbd> + <kbd>COMMAND (⌘)</kbd> + <kbd>DELETE (⌫)</kbd>.
10. To disable Maccy and ignore new copies, click on the menu icon with <kbd>OPTION (⌥)</kbd> pressed.
11. To ignore only the next copy, click on the menu icon with <kbd>OPTION (⌥)</kbd> + <kbd>SHIFT (⇧)</kbd> pressed.
12. To customize the behavior, check "Preferences…" window, or press <kbd>COMMAND (⌘)</kbd> + <kbd>,</kbd>.

## Advanced

### Ignore Copied Items

You can tell Maccy to ignore all copied items:

```sh
defaults write org.p0deje.Maccy ignoreEvents true # default is false
```

This is useful if you have some workflow for copying sensitive data. You can set `ignoreEvents` to true, copy the data and set `ignoreEvents` back to false.

You can also click the menu icon with <kbd>OPTION (⌥)</kbd> pressed. To ignore only the next copy, click with <kbd>OPTION (⌥)</kbd> + <kbd>SHIFT (⇧)</kbd> pressed.

### Ignore Custom Copy Types

By default Maccy will ignore certain copy types that are considered to be confidential
or temporary. The default list always include the following types:

* `org.nspasteboard.TransientType`
* `org.nspasteboard.ConcealedType`
* `org.nspasteboard.AutoGeneratedType`

Also, default configuration includes the following types but they can be removed
or overwritten:

* `com.agilebits.onepassword`
* `com.typeit4me.clipping`
* `de.petermaurer.TransientPasteboardType`
* `Pasteboard generator type`
* `net.antelle.keeweb`

You can add additional custom types using settings.
To find what custom types are used by an application, you can use
free application [Pasteboard-Viewer](https://github.com/sindresorhus/Pasteboard-Viewer).
Simply download the application, open it, copy something from the application you
want to ignore and look for any custom types in the left sidebar. [Here is an example
of using this approach to ignore Adobe InDesign](https://github.com/p0deje/Maccy/issues/125).

### Speed up Clipboard Check Interval

By default, Maccy checks clipboard every 500 ms, which should be enough for most users. If you want
to speed it up, you can change it with `defaults`:

```sh
defaults write org.p0deje.Maccy clipboardCheckInterval 0.1 # 100 ms
```

## FAQ

### Why doesn't it paste when I select an item in history?

1. Make sure you have "Paste automatically" enabled in Preferences.
2. Make sure "Maccy" is added to System Settings -> Privacy & Security -> Accessibility.

### When assigning a hotkey to open Maccy, it says that this hotkey is already used in some system setting.

1. Open System settings -> Keyboard -> Keyboard Shortcuts.
2. Find where that hotkey is used. For example, "Convert text to simplified Chinese" is under Services -> Text.
3. Disable that hotkey or remove assigned combination ([screenshot](https://github.com/p0deje/Maccy/assets/576152/446719e6-c3e5-4eb0-95fb-5a811066487f)).
4. Restart Maccy.
5. Assign hotkey in Maccy settings.

### How to restore hidden footer?

1. Open Maccy window.
2. Press <kbd>COMMAND (⌘)</kbd> + <kbd>,</kbd> to open preferences.
3. Enable footer in Appearance section.

If for some reason it doesn't work, run the following command in Terminal.app:

```sh
defaults write org.p0deje.Maccy showFooter 1
```

### How to ignore copies from [Universal Clipboard](https://support.apple.com/en-us/102430)?

1. Open Preferences -> Ignore -> Pasteboard Types.
2. Add `com.apple.is-remote-clipboard`.

### My keyboard shortcut stopped working in password fields. How do I fix this?

If your shortcut produces a character (like `Option+C` → "ç"), macOS security may block it in password fields. Use [Karabiner-Elements](https://karabiner-elements.pqrs.org/) to remap your shortcut to a different combination like `Cmd+Shift+C`. [See detailed solution](docs/keyboard-shortcut-password-fields.md).

## Translations

The translations are hosted in [Weblate](https://hosted.weblate.org/engage/maccy/).
You can use it to suggest changes in translations and localize the application to a new language.

[![Translation status](https://hosted.weblate.org/widget/maccy/multi-auto.svg)](https://hosted.weblate.org/engage/maccy/)

## Motivation

There are dozens of similar applications out there, so why build another?
Over the past years since I moved from Linux to macOS, I struggled to find
a clipboard manager that is as free and simple as [Parcellite](http://parcellite.sourceforge.net),
but I couldn't. So I've decided to build one.

Also, I wanted to learn Swift and get acquainted with macOS application development.

## License

[MIT](./LICENSE)
