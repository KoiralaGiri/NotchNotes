import SwiftUI
import SwiftData

struct NotchContentView: View {
    @Query(filter: #Predicate<Note> { note in
        note.isPinned
    }, sort: \Note.updatedAt, order: .reverse) private var pinnedNotes: [Note]

    @State private var selectedNote: Note? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.orange)
                    
                    Text(selectedNote != nil ? "Pinned Note" : "Pinned Notes")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Back button when viewing a note
                if selectedNote != nil {
                    Button {
                        selectedNote = nil
                        // Collapse back to compact
                        if NotchPanelManager.shared.isPanelExpanded {
                            NotchPanelManager.shared.toggleExpand()
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 10, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.primary.opacity(0.06))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)
            
            Divider()
                .opacity(0.3)
                .padding(.horizontal, 12)

            // Content
            if pinnedNotes.isEmpty {
                emptyState
            } else if let note = selectedNote {
                // Show the selected note in full
                noteDetailView(note)
            } else {
                // Show list of all pinned notes to pick from
                notePickerList
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThickMaterial)
        )
        .clipShape(
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 0,
                    bottomLeading: 16,
                    bottomTrailing: 16,
                    topTrailing: 0
                )
            )
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .onHover { isHovering in
            if isHovering {
                NotchPanelManager.shared.cancelHideTimer()
            } else {
                NotchPanelManager.shared.startHideTimer()
            }
        }
    }
    
    // MARK: - Note Picker List
    
    private var notePickerList: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 2) {
                ForEach(pinnedNotes) { note in
                    Button {
                        selectedNote = note
                        // Auto-expand to show full note
                        if !NotchPanelManager.shared.isPanelExpanded {
                            NotchPanelManager.shared.toggleExpand()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            // Color indicator dot
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 8, height: 8)
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(note.title)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                if !note.preview.isEmpty {
                                    Text(note.preview)
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                
                                Text(note.updatedAt, format: .relative(presentation: .named))
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary.opacity(0.5))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary.opacity(0.4))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.primary.opacity(0.04))
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Note Detail View
    
    @ViewBuilder
    private func noteDetailView(_ note: Note) -> some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 8) {
                // Render rich text if available, otherwise plain text
                if let rtfData = note.rtfData,
                   let nsAttrStr = NSAttributedString(rtf: rtfData, documentAttributes: nil) {
                    // Convert NSAttributedString → SwiftUI AttributedString
                    // This preserves bold, italic, colors, highlights, font sizes
                    if let swiftAttrStr = try? AttributedString(nsAttrStr, including: \.appKit) {
                        Text(swiftAttrStr)
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        // Fallback: plain conversion
                        Text(AttributedString(nsAttrStr))
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } else if !note.content.isEmpty {
                    Text(note.content)
                        .font(.system(size: 14))
                        .foregroundColor(.primary.opacity(0.9))
                        .textSelection(.enabled)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("Empty note")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                // Timestamp
                HStack {
                    Spacer()
                    Text(note.updatedAt, format: .relative(presentation: .named))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.5))
                }
                .padding(.top, 8)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "pin.slash")
                .font(.system(size: 28, weight: .ultraLight))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange.opacity(0.5), .pink.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("No pinned notes")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("Pin a note from the app")
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
    
    /// Extract body text (everything after first line)
    private func extractBody(from content: String) -> String {
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
        guard lines.count > 1 else { return "" }
        return lines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    NotchContentView()
        .modelContainer(for: Note.self, inMemory: true)
}
