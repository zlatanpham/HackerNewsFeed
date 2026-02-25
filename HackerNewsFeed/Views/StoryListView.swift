import SwiftUI

struct StoryListView: View {
    @ObservedObject var viewModel: StoriesViewModel
    @State private var isRefreshing = false
    @State private var dragOffset: CGFloat = 0
    private let refreshThreshold: CGFloat = 60

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
            } else if viewModel.stories.isEmpty {
                EmptyStateView(timeFilter: viewModel.selectedTimeFilter)
            } else {
                ScrollViewReader { proxy in
                    VStack(spacing: 0) {
                        // Refresh indicator above the list
                        if dragOffset > 0 || isRefreshing {
                            RefreshIndicator(
                                dragOffset: dragOffset,
                                threshold: refreshThreshold,
                                isRefreshing: isRefreshing
                            )
                        }

                        ScrollView {
                            LazyVStack(spacing: 0) {
                                Color.clear
                                    .frame(height: 0)
                                    .id("top")

                                ForEach(viewModel.stories) { story in
                                    StoryRowView(
                                        story: story,
                                        isRead: viewModel.isRead(story),
                                        onOpen: { viewModel.openStory(story) },
                                        onOpenComments: { viewModel.openComments(story) },
                                        onOpenAuthor: { viewModel.openAuthor(story) },
                                        onCopyLink: { viewModel.copyLink(story) }
                                    )
                                    Divider()
                                        .padding(.leading, 12)
                                }
                            }
                        }
                        .gesture(
                            DragGesture(minimumDistance: 10)
                                .onChanged { value in
                                    guard !isRefreshing else { return }
                                    let vertical = value.translation.height
                                    // Only respond to downward drags
                                    if vertical > 0 {
                                        withAnimation(.interactiveSpring()) {
                                            dragOffset = vertical
                                        }
                                    }
                                }
                                .onEnded { value in
                                    guard !isRefreshing else { return }
                                    if value.translation.height > refreshThreshold {
                                        isRefreshing = true
                                        withAnimation(.spring()) {
                                            dragOffset = 0
                                        }
                                        Task {
                                            await viewModel.refresh()
                                            proxy.scrollTo("top", anchor: .top)
                                            withAnimation(.spring()) {
                                                isRefreshing = false
                                            }
                                        }
                                    } else {
                                        withAnimation(.spring()) {
                                            dragOffset = 0
                                        }
                                    }
                                }
                        )
                    }
                    .onChange(of: viewModel.selectedStoryType) { _, _ in
                        proxy.scrollTo("top", anchor: .top)
                    }
                    .onChange(of: viewModel.selectedTimeFilter) { _, _ in
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }
        }
    }
}

struct RefreshIndicator: View {
    let dragOffset: CGFloat
    let threshold: CGFloat
    let isRefreshing: Bool

    var body: some View {
        HStack(spacing: 8) {
            if isRefreshing {
                ProgressView()
                    .controlSize(.small)
                Text("Refreshing...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                let progress = min(dragOffset / threshold, 1.0)
                Image(systemName: "arrow.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(progress >= 1.0 ? 180 : 0))
                    .animation(.easeInOut(duration: 0.2), value: progress >= 1.0)
                Text(progress >= 1.0 ? "Release to refresh" : "Pull down to refresh")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: isRefreshing ? 36 : min(max(dragOffset * 0.5, 0), 36))
        .clipped()
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
