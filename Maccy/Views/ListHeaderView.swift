import Defaults
import KeyboardShortcuts
import SwiftUI

struct ListHeaderView: View {
  @FocusState.Binding var searchFocused: Bool
  @Binding var searchQuery: String

  @Environment(AppState.self) private var appState
  @Environment(\.scenePhase) private var scenePhase

  @Default(.showTitle) private var showTitle

  var body: some View {
    HStack(spacing: 6) {
      if showTitle {
        Text("Maccy")
          .font(.system(size: 13, weight: .semibold))
          .foregroundStyle(.secondary)
          .padding(.leading, 5)
      }

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
