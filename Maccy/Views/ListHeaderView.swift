import Defaults
import KeyboardShortcuts
import SwiftUI

struct ListHeaderView: View {
  @FocusState.Binding var searchFocused: Bool
  @Binding var searchQuery: String

  @Environment(AppState.self) private var appState
  @Environment(\.scenePhase) private var scenePhase

  var body: some View {
    HStack(spacing: 6) {
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
            .font(.system(size: 12))
        }
      }
      .help(Text("clear_tooltip"))
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
