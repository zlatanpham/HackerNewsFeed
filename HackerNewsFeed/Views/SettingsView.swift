import SwiftUI

struct SettingsView: View {
    @ObservedObject private var launchAtLoginManager = LaunchAtLoginManager.shared

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    Toggle(isOn: $launchAtLoginManager.isEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Start at Login")
                            Text("Automatically launch HackerNewsFeed when you log in")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("System")
                }
            }
            .formStyle(.grouped)

            Divider()

            // About section
            VStack(spacing: 12) {
                if let appIcon = NSImage(named: NSImage.applicationIconName) {
                    Image(nsImage: appIcon)
                        .resizable()
                        .frame(width: 64, height: 64)
                }

                Text("HackerNewsFeed")
                    .font(.headline)

                Text("Version \(appVersion) (\(buildNumber))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 16) {
                    Link(destination: URL(string: "https://github.com/example/HackerNewsFeed")!) {
                        Label("GitHub", systemImage: "link")
                            .font(.caption)
                    }
                }

                HStack(spacing: 4) {
                    Text("Made with ❤️ by")
                    Link("Zlatan Pham", destination: URL(string: "https://github.com/zlatanpham/")!)
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Text("Copyright \(Calendar.current.component(.year, from: Date())). All rights reserved.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(width: 400, height: 350)
    }
}

#Preview {
    SettingsView()
}
