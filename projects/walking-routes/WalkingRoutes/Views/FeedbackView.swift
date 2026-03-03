import SwiftUI

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackText: String = ""
    @State private var email: String = ""
    @State private var showConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Your Feedback")) {
                    TextEditor(text: $feedbackText)
                        .frame(minHeight: 120)
                        .overlay(
                            Group {
                                if feedbackText.isEmpty {
                                    Text("Tell us what you think, report a bug, or suggest a feature...")
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                }
                            },
                            alignment: .topLeading
                        )
                }

                Section(header: Text("Email (Optional)")) {
                    TextField("your@email.com", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }

                Section {
                    Button(action: submitFeedback) {
                        HStack {
                            Spacer()
                            Text("Submit Feedback")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Send Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Thank You!", isPresented: $showConfirmation) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your feedback has been saved. We appreciate your input!")
            }
        }
    }

    private func submitFeedback() {
        let trimmedFeedback = feedbackText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedFeedback.isEmpty else { return }

        let feedbackEntry = FeedbackEntry(
            text: trimmedFeedback,
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            timestamp: Date()
        )

        FeedbackStorage.shared.saveFeedback(feedbackEntry)
        showConfirmation = true
    }
}

struct FeedbackEntry: Codable, Identifiable {
    let id: UUID
    let text: String
    let email: String
    let timestamp: Date

    init(id: UUID = UUID(), text: String, email: String, timestamp: Date) {
        self.id = id
        self.text = text
        self.email = email
        self.timestamp = timestamp
    }
}

class FeedbackStorage {
    static let shared = FeedbackStorage()
    private let userDefaultsKey = "walking_routes_feedback"

    private init() {}

    func saveFeedback(_ entry: FeedbackEntry) {
        var allFeedback = loadAllFeedback()
        allFeedback.append(entry)

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(allFeedback)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            print("[FeedbackStorage] Saved feedback entry with ID: \(entry.id)")
        } catch {
            print("[FeedbackStorage] Failed to save feedback: \(error.localizedDescription)")
        }
    }

    func loadAllFeedback() -> [FeedbackEntry] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return []
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([FeedbackEntry].self, from: data)
        } catch {
            print("[FeedbackStorage] Failed to load feedback: \(error.localizedDescription)")
            return []
        }
    }

    func clearAllFeedback() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        print("[FeedbackStorage] Cleared all feedback")
    }
}

#Preview {
    FeedbackView()
}
