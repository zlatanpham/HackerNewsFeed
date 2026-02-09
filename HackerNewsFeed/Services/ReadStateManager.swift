import Foundation

@MainActor
class ReadStateManager: ObservableObject {
    static let shared = ReadStateManager()

    private static let userDefaultsKey = "readStoryIDs"
    private static let maxStoredIDs = 2000

    @Published private(set) var readStoryIDs: Set<Int>

    private init() {
        let stored = UserDefaults.standard.array(forKey: Self.userDefaultsKey) as? [Int] ?? []
        self.readStoryIDs = Set(stored)
    }

    func isRead(_ storyID: Int) -> Bool {
        readStoryIDs.contains(storyID)
    }

    func markAsRead(_ storyID: Int) {
        guard !readStoryIDs.contains(storyID) else { return }
        readStoryIDs.insert(storyID)
        persist()
    }

    private func persist() {
        var ids = Array(readStoryIDs)
        if ids.count > Self.maxStoredIDs {
            // Keep highest IDs (newest stories)
            ids.sort(by: >)
            ids = Array(ids.prefix(Self.maxStoredIDs))
            readStoryIDs = Set(ids)
        }
        UserDefaults.standard.set(ids, forKey: Self.userDefaultsKey)
    }
}
