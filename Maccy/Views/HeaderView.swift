import Defaults
import SwiftUI

struct HeaderView: View {
  @State private var appState = AppState.shared

  let controller: SlideoutController
  @FocusState.Binding var searchFocused: Bool

  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      ListHeaderView(
        controller: controller,
        searchFocused: $searchFocused,
        searchQuery: $appState.history.searchQuery
      )
    }
    .opacity(appState.searchVisible ? 1 : 0)
    .accessibilityHidden(!appState.searchVisible)
    .layoutPriority(1)
    .padding(.horizontal, 10)
    .padding(.top, 8)
    .padding(.bottom, 6)
    .animation(.default.speed(3), value: appState.navigator.leadSelection)
    .background(.clear)
    .contentShape(Rectangle())
    .onTapGesture(count: 2) {
      appState.showContextMenu(inHeader: true)
    }
    .frame(maxHeight: !appState.searchVisible ? 0 : nil, alignment: .top)
    .readHeight(appState, into: \.popup.headerHeight)
  }
}
