import Defaults
import KeyboardShortcuts
import SwiftUI

struct ListHeaderView: View {
  let controller: SlideoutController
  @FocusState.Binding var searchFocused: Bool
  @Binding var searchQuery: String

  @Environment(AppState.self) private var appState
  @Environment(\.scenePhase) private var scenePhase

  var previewPlacement: SlideoutPlacement {
    return controller.placement
  }

  var body: some View {
    HStack(alignment: .center, spacing: 8) {
      SearchFieldView(placeholder: "search_placeholder", query: $searchQuery)
        .focused($searchFocused)
        .frame(maxWidth: .infinity)
        .onChange(of: scenePhase) {
          if scenePhase == .background && !searchQuery.isEmpty {
            searchQuery = ""
          }
        }
        // Only reliable way to disable the cursor. allowsHitTesting() does not work
        .offset(y: appState.searchVisible ? 0 : -Popup.itemHeight)

      ConfirmationView(item: appState.footer.items[0]) {
        ToolbarButton {
          if appState.footer.items[0].suppressConfirmation?.wrappedValue == true {
            appState.footer.items[0].action()
          } else {
            appState.footer.items[0].showConfirmation = true
          }
        } label: {
          Image(systemName: "trash")
            .font(.system(size: 13, weight: .regular))
            .frame(width: 22, height: 23)
            .contentShape(Rectangle())
        }
      }
      .help(Text("clear_tooltip"))

      ToolbarButton {
        controller.togglePreview()
      } label: {
        Image(
          systemName: previewPlacement == .right
            ? "sidebar.left" : "sidebar.right"
        )
        .font(.system(size: 13, weight: .regular))
        .frame(width: 22, height: 23)
        .contentShape(Rectangle())
      }
      .shortcutKeyHelp(
        name: .togglePreview,
        key: controller.state.isOpen ? "ClosePreview" : "OpenPreview",
        tableName: "PreviewItemView",
        replacementKey: "previewKey"
      )
    }
    .contentShape(Rectangle())
    .onTapGesture(count: 2) {
      appState.showContextMenu(inHeader: true)
    }
    .contextMenu {
      Button {
        appState.openPreferences()
      } label: {
        Text("preferences")
      }
      .keyboardShortcut(",", modifiers: .command)

      Button {
        appState.openAbout()
      } label: {
        Text("about")
      }

      Button {
        appState.quit()
      } label: {
        Text("quit")
      }
      .keyboardShortcut("q", modifiers: .command)
    }
  }
}
