import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StoriesViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header with tabs
            VStack(spacing: 8) {
                // Tab buttons
                HStack(spacing: 4) {
                    ForEach(StoryType.allCases) { storyType in
                        TabButton(
                            title: storyType.title,
                            icon: storyType.iconName,
                            isSelected: viewModel.selectedStoryType == storyType
                        ) {
                            viewModel.selectedStoryType = storyType
                        }
                    }
                }

                // Time filter
                TimeFilterPicker(selection: $viewModel.selectedTimeFilter)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()

            // Story list
            StoryListView(viewModel: viewModel)

            // Footer
            Divider()
            HStack(spacing: 12) {
                Button("Settings...") {
                    AppDelegate.shared?.openSettings()
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Spacer()

                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            .font(.system(size: 12))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 350, height: 500)
        .task(id: "\(viewModel.selectedStoryType.id)-\(viewModel.selectedTimeFilter.id)") {
            await viewModel.loadStories()
        }
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
