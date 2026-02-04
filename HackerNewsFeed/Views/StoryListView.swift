import SwiftUI

struct StoryListView: View {
    @ObservedObject var viewModel: StoriesViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.stories.isEmpty {
                LoadingView()
            } else if let error = viewModel.error, viewModel.stories.isEmpty {
                ErrorView(message: error) {
                    Task {
                        await viewModel.refresh()
                    }
                }
            } else if viewModel.filteredStories.isEmpty {
                EmptyStateView(timeFilter: viewModel.selectedTimeFilter)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.filteredStories) { story in
                            StoryRowView(
                                story: story,
                                onOpen: { viewModel.openStory(story) },
                                onOpenComments: { viewModel.openComments(story) },
                                onCopyLink: { viewModel.copyLink(story) }
                            )
                            Divider()
                                .padding(.leading, 12)
                        }
                    }
                }
            }
        }
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text("Failed to load stories")
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                onRetry()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct EmptyStateView: View {
    let timeFilter: TimeFilter

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text("No stories found")
                .font(.headline)
            if timeFilter != .all {
                Text("Try expanding the time filter")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    StoryListView(viewModel: StoriesViewModel())
        .frame(width: 350, height: 400)
}
