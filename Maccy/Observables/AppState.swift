import AppKit
import Defaults
import Foundation
import Settings
import SwiftUI

@Observable
class AppState: Sendable {
  static let shared = AppState(history: History.shared, footer: Footer())

  let multiSelectionEnabled = false

  var appDelegate: AppDelegate?
  var popup: Popup
  var history: History
  var footer: Footer
  var navigator: NavigationManager
  var preview: SlideoutController

  var isEditingItem: Bool = false
  var suppressPopupAutoClose: Bool {
    return navigator.isDragAndDropInProgress || isEditingItem
  }

  var searchVisible: Bool {
    if !Defaults[.showSearch] { return false }
    switch Defaults[.searchVisibility] {
    case .always: return true
    case .duringSearch: return !history.searchQuery.isEmpty
    }
  }

  var menuIconText: String {
    var title = history.firstUnpinnedItem?.text.shortened(to: 100)
      .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    title.unicodeScalars.removeAll(where: CharacterSet.newlines.contains)
    return title.shortened(to: 20)
  }

  private let about = About()
  private var settingsWindowController: SettingsWindowController?

  init(history: History, footer: Footer) {
    self.history = history
    self.footer = footer
    popup = Popup()
    navigator = NavigationManager(history: history, footer: footer)
    preview = SlideoutController(
      onContentResize: { contentWidth in
        Defaults[.windowSize].width = contentWidth
      },
      onSlideoutResize: { previewWidth in
        Defaults[.previewWidth] = previewWidth
      })
    preview.contentWidth = Defaults[.windowSize].width
    preview.slideoutWidth = Defaults[.previewWidth]
  }

  @MainActor
  func select(flags modifierFlags: NSEvent.ModifierFlags) {
    if !navigator.selection.isEmpty {
      if navigator.isMultiSelectInProgress {
        navigator.isManualMultiSelect = false
        history.startPasteStack(selection: &navigator.selection, flags: modifierFlags)
      } else {
        history.select(navigator.selection.first, flags: modifierFlags)
      }
    } else if let item = footer.selectedItem {
      // TODO: Use item.suppressConfirmation, but it's not updated!
      if item.confirmation != nil, Defaults[.suppressClearAlert] == false {
        item.showConfirmation = true
      } else {
        item.action()
      }
    } else {
      Clipboard.shared.copyInMaccy(history.searchQuery)
      history.searchQuery = ""
    }
  }

  @MainActor
  func togglePin() {
    withTransaction(Transaction()) {
      navigator.selection.forEach { _, item in
        history.togglePin(item)
      }
    }
  }

  @MainActor
  func removePasteStack() {
    history.interruptPasteStack()
    navigator.highlightFirst()
  }

  @MainActor
  func deleteSelection() {
    guard let leadItem = navigator.leadHistoryItem else { return }
    let nextUnselectedItem = history.nearestVisible(to: leadItem) { !$0.isSelected }

    withTransaction(Transaction()) {
      navigator.selection.forEach { _, item in
        history.delete(item)
      }
      navigator.select(item: nextUnselectedItem)
    }
  }

  func openAbout() {
    about.openAbout(nil)
  }

  @MainActor
  func openPreferences() { // swiftlint:disable:this function_body_length
    if settingsWindowController == nil {
      let generalTitle = NSLocalizedString("Title", tableName: "GeneralSettings", comment: "")
      let storageTitle = NSLocalizedString("Title", tableName: "StorageSettings", comment: "")
      let appearanceTitle = NSLocalizedString("Title", tableName: "AppearanceSettings", comment: "")
      let ignoreTitle = NSLocalizedString("Title", tableName: "IgnoreSettings", comment: "")
      let advancedTitle = NSLocalizedString("Title", tableName: "AdvancedSettings", comment: "")
      let toolbarTitles = [generalTitle, storageTitle, appearanceTitle, ignoreTitle, advancedTitle]
      let titleAttributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: NSFont.systemFontSize)]
      let titleWidth = toolbarTitles.reduce(CGFloat.zero) {
        $0 + ($1 as NSString).size(withAttributes: titleAttributes).width
      }
      let toolbarItemSpacing: CGFloat = 24
      let toolbarEdgeSpacing: CGFloat = 40
      let toolbarWidth = titleWidth + CGFloat(toolbarTitles.count) * toolbarItemSpacing + toolbarEdgeSpacing
      let minimumWidth = max(500, ceil(toolbarWidth))
      settingsWindowController = SettingsWindowController(
        panes: [
          Settings.Pane(
            identifier: Settings.PaneIdentifier.general,
            title: generalTitle,
            toolbarIcon: NSImage.gearshape!
          ) {
            GeneralSettingsPane()
              .frame(minWidth: minimumWidth)
          },
          Settings.Pane(
            identifier: Settings.PaneIdentifier.storage,
            title: storageTitle,
            toolbarIcon: NSImage.externaldrive!
          ) {
            StorageSettingsPane()
              .frame(minWidth: minimumWidth)
          },
          Settings.Pane(
            identifier: Settings.PaneIdentifier.appearance,
            title: appearanceTitle,
            toolbarIcon: NSImage.paintpalette!
          ) {
            AppearanceSettingsPane()
              .frame(minWidth: minimumWidth)
          },
          Settings.Pane(
            identifier: Settings.PaneIdentifier.ignore,
            title: ignoreTitle,
            toolbarIcon: NSImage.nosign!
          ) {
            IgnoreSettingsPane()
              .frame(minWidth: minimumWidth)
          },
          Settings.Pane(
            identifier: Settings.PaneIdentifier.advanced,
            title: advancedTitle,
            toolbarIcon: NSImage.gearshape2!
          ) {
            AdvancedSettingsPane()
              .frame(minWidth: minimumWidth)
          }
        ]
      )
    }
    settingsWindowController?.show()
    settingsWindowController?.window?.orderFrontRegardless()
  }

  func quit() {
    NSApp.terminate(self)
  }

  @MainActor
  func buildContextMenu(inHeader: Bool = false) -> NSMenu {
    let menu = NSMenu(title: "Maccy")
    var targets: [Any] = []

    if !inHeader,
       let selectedId = navigator.leadSelection,
       let item = history.items.first(where: { $0.id == selectedId }) {
      let pasteTarget = MenuActionTarget { [weak self] in
        self?.history.select(item)
      }
      targets.append(pasteTarget)
      let pasteItem = NSMenuItem(
        title: NSLocalizedString("history_item_paste_action", value: "Paste", comment: ""),
        action: #selector(MenuActionTarget.trigger),
        keyEquivalent: "\r"
      )
      pasteItem.target = pasteTarget
      menu.addItem(pasteItem)

      let copyTarget = MenuActionTarget { [weak self] in
        self?.popup.close()
        Clipboard.shared.copy(item.item)
      }
      targets.append(copyTarget)
      let copyItem = NSMenuItem(
        title: NSLocalizedString("history_item_copy_action", value: "Copy", comment: ""),
        action: #selector(MenuActionTarget.trigger),
        keyEquivalent: "c"
      )
      copyItem.target = copyTarget
      copyItem.keyEquivalentModifierMask = [.command]
      menu.addItem(copyItem)

      let pinTarget = MenuActionTarget { [weak self] in
        self?.history.togglePin(item)
      }
      targets.append(pinTarget)
      let pinTitle = item.isPinned ?
        NSLocalizedString("history_item_unpin_action", comment: "") :
        NSLocalizedString("history_item_pin_action", comment: "")
      let pinItem = NSMenuItem(
        title: pinTitle,
        action: #selector(MenuActionTarget.trigger),
        keyEquivalent: "p"
      )
      pinItem.target = pinTarget
      pinItem.keyEquivalentModifierMask = [.option]
      menu.addItem(pinItem)

      let deleteTarget = MenuActionTarget { [weak self] in
        self?.history.delete(item)
      }
      targets.append(deleteTarget)
      let deleteItem = NSMenuItem(
        title: NSLocalizedString("history_item_delete_action", comment: ""),
        action: #selector(MenuActionTarget.trigger),
        keyEquivalent: "\u{7f}"
      )
      deleteItem.target = deleteTarget
      deleteItem.keyEquivalentModifierMask = [.option]
      menu.addItem(deleteItem)

      menu.addItem(NSMenuItem.separator())
    }

    let prefsTarget = MenuActionTarget { [weak self] in self?.openPreferences() }
    targets.append(prefsTarget)
    let prefsItem = NSMenuItem(
      title: NSLocalizedString("preferences", comment: ""),
      action: #selector(MenuActionTarget.trigger),
      keyEquivalent: ","
    )
    prefsItem.target = prefsTarget
    prefsItem.keyEquivalentModifierMask = [.command]
    menu.addItem(prefsItem)

    let aboutTarget = MenuActionTarget { [weak self] in self?.openAbout() }
    targets.append(aboutTarget)
    let aboutItem = NSMenuItem(
      title: NSLocalizedString("about", comment: ""),
      action: #selector(MenuActionTarget.trigger),
      keyEquivalent: ""
    )
    aboutItem.target = aboutTarget
    menu.addItem(aboutItem)

    if !inHeader {
      menu.addItem(NSMenuItem.separator())
    }

    let quitTarget = MenuActionTarget { [weak self] in self?.quit() }
    targets.append(quitTarget)
    let quitItem = NSMenuItem(
      title: NSLocalizedString("quit", comment: ""),
      action: #selector(MenuActionTarget.trigger),
      keyEquivalent: "q"
    )
    quitItem.target = quitTarget
    quitItem.keyEquivalentModifierMask = [.command]
    menu.addItem(quitItem)

    objc_setAssociatedObject(menu, "menuTargets", targets, .OBJC_ASSOCIATION_RETAIN)
    return menu
  }

  @MainActor
  func showContextMenu(at screenPoint: NSPoint? = nil, inHeader: Bool = false) {
    let menu = buildContextMenu(inHeader: inHeader)
    let point = screenPoint ?? NSEvent.mouseLocation
    menu.popUp(positioning: nil, at: point, in: nil)
  }
}

final class MenuActionTarget: NSObject {
  private let action: () -> Void

  init(_ action: @escaping () -> Void) {
    self.action = action
    super.init()
  }

  @objc func trigger() {
    action()
  }
}
