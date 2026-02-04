import SwiftUI

struct StoryRowView: View {
    let story: Story
    let onOpen: () -> Void
    let onOpenComments: () -> Void
    let onCopyLink: () -> Void

    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Title
            Text(story.displayTitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            // Domain
            if let domain = story.domain {
                Text(domain)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            // Metadata row
            HStack(spacing: 12) {
                // Score
                HStack(spacing: 3) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 9))
                    Text("\(story.displayScore)")
                }
                .foregroundStyle(.orange)

                // Comments
                HStack(spacing: 3) {
                    Image(systemName: "bubble.right")
                        .font(.system(size: 9))
                    Text("\(story.commentCount)")
                }
                .foregroundStyle(.secondary)

                // Author
                HStack(spacing: 3) {
                    Image(systemName: "person")
                        .font(.system(size: 9))
                    Text(story.displayAuthor)
                }
                .foregroundStyle(.secondary)

                Spacer()

                // Time ago
                if let date = story.timeDate {
                    Text(date.timeAgoDisplay())
                        .foregroundStyle(.secondary)
                }
            }
            .font(.system(size: 11))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(isHovered ? Color.primary.opacity(0.05) : Color.clear)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            onOpen()
        }
        .contextMenu {
            Button("Open Story") {
                onOpen()
            }
            Button("Open Comments") {
                onOpenComments()
            }
            Divider()
            Button("Copy Link") {
                onCopyLink()
            }
        }
    }
}

#Preview {
    StoryRowView(
        story: Story(
            id: 1,
            title: "Show HN: A very long title that might wrap to two lines in the compact view",
            url: "https://example.com/article",
            score: 256,
            by: "johndoe",
            time: Int(Date().timeIntervalSince1970) - 3600,
            descendants: 42
        ),
        onOpen: {},
        onOpenComments: {},
        onCopyLink: {}
    )
    .frame(width: 350)
}
