import SwiftUI

struct StoryRowView: View {
    let story: Story
    let isRead: Bool
    let onOpen: () -> Void
    let onOpenComments: () -> Void
    let onOpenAuthor: () -> Void
    let onCopyLink: () -> Void

    @State private var isHovered = false
    @State private var isScoreHovered = false
    @State private var isCommentsHovered = false
    @State private var isAuthorHovered = false

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
                // Score - clickable, opens HN thread
                HStack(spacing: 3) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 9))
                    Text("\(story.displayScore)")
                }
                .foregroundStyle(Color(red: 1.0, green: 0.4, blue: 0.0).opacity(isScoreHovered ? 0.7 : 1.0))
                .onHover { hovering in
                    isScoreHovered = hovering
                }
                .onTapGesture {
                    onOpenComments()
                }

                // Comments - clickable, opens HN thread
                HStack(spacing: 3) {
                    Image(systemName: "bubble.right")
                        .font(.system(size: 9))
                    Text("\(story.commentCount)")
                }
                .foregroundStyle(isCommentsHovered ? .primary : .secondary)
                .onHover { hovering in
                    isCommentsHovered = hovering
                }
                .onTapGesture {
                    onOpenComments()
                }

                // Author - clickable, opens author profile
                HStack(spacing: 3) {
                    Image(systemName: "person")
                        .font(.system(size: 9))
                    Text(story.displayAuthor)
                }
                .foregroundStyle(isAuthorHovered ? .primary : .secondary)
                .onHover { hovering in
                    isAuthorHovered = hovering
                }
                .onTapGesture {
                    onOpenAuthor()
                }

                Spacer()

                // Time ago
                if let date = story.timeDate {
                    Text(date.timeAgoDisplay())
                        .foregroundStyle(.secondary)
                }
            }
            .font(.system(size: 11))
        }
        .opacity(isRead ? 0.55 : 1.0)
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
    VStack(spacing: 0) {
        StoryRowView(
            story: Story(
                id: 1,
                title: "Show HN: An unread story with a long title that might wrap",
                url: "https://example.com/article",
                score: 256,
                by: "johndoe",
                time: Int(Date().timeIntervalSince1970) - 3600,
                descendants: 42
            ),
            isRead: false,
            onOpen: {},
            onOpenComments: {},
            onOpenAuthor: {},
            onCopyLink: {}
        )
        Divider()
        StoryRowView(
            story: Story(
                id: 2,
                title: "Show HN: A read story that has been opened before",
                url: "https://example.com/other",
                score: 128,
                by: "janedoe",
                time: Int(Date().timeIntervalSince1970) - 7200,
                descendants: 15
            ),
            isRead: true,
            onOpen: {},
            onOpenComments: {},
            onOpenAuthor: {},
            onCopyLink: {}
        )
    }
    .frame(width: 350)
}
