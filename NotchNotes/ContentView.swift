import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.createdAt, order: .reverse) private var notes: [Note]

    @State private var selectedNote: Note?
    @State private var searchText = ""

    var filteredNotes: [Note] {
        if searchText.isEmpty { return notes }
        return notes.filter {
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                // Search
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                    TextField("Search notes…", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13))
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor))
                )
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 4)

                List(selection: $selectedNote) {
                    ForEach(filteredNotes) { note in
                        NavigationLink(value: note) {
                            NoteRow(note: note)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteNote(note)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                note.isPinned.toggle()
                            } label: {
                                Label(
                                    note.isPinned ? "Unpin" : "Pin to Notch",
                                    systemImage: note.isPinned ? "pin.slash" : "pin"
                                )
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(.sidebar)
            }
            .navigationSplitViewColumnWidth(min: 230, ideal: 270, max: 350)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: addItem) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .help("New Note")
                }
            }
        } detail: {
            if let note = selectedNote {
                NoteEditorView(note: note, onDelete: {
                    deleteNote(note)
                })
                .id(note.id)
            } else {
                EmptyStateView()
            }
        }
    }

    private func addItem() {
        withAnimation(.easeInOut(duration: 0.2)) {
            let newItem = Note(content: "", isPinned: false)
            modelContext.insert(newItem)
            selectedNote = newItem
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation(.easeInOut(duration: 0.2)) {
            let notesToDelete = offsets.map { filteredNotes[$0] }
            for note in notesToDelete {
                modelContext.delete(note)
            }
            if let selected = selectedNote, notesToDelete.contains(where: { $0.id == selected.id }) {
                selectedNote = nil
            }
        }
    }

    private func deleteNote(_ note: Note) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if selectedNote?.id == note.id {
                selectedNote = nil
            }
            modelContext.delete(note)
        }
    }
}

// MARK: - Note Row

struct NoteRow: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(note.title)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.orange)
                }
            }

            if !note.preview.isEmpty {
                Text(note.preview)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Text(note.updatedAt, format: .relative(presentation: .named))
                .font(.system(size: 10))
                .foregroundColor(.secondary.opacity(0.6))
        }
        .padding(.vertical, 3)
    }
}

// MARK: - Note Editor — Document-like layout

struct NoteEditorView: View {
    @Bindable var note: Note
    var onDelete: () -> Void
    @State private var coordinator = RichTextCoordinator()
    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            // Header bar
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(note.title)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                    
                    Text(note.updatedAt, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Toggle(isOn: $note.isPinned) {
                    Label(
                        note.isPinned ? "Unpin" : "Pin to Notch",
                        systemImage: note.isPinned ? "pin.fill" : "pin"
                    )
                }
                .toggleStyle(.button)
                .controlSize(.small)
                .tint(note.isPinned ? .orange : .secondary)

                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                }
                .controlSize(.small)
                .help("Delete note")
                .alert("Delete Note?", isPresented: $showDeleteConfirm) {
                    Button("Delete", role: .destructive, action: onDelete)
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This note will be permanently deleted.")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(NSColor.windowBackgroundColor))

            // Formatting toolbar
            FormattingToolbar(coordinator: coordinator)

            Divider()

            // Document editor — fills all available space, scrollable like Google Docs
            RichTextEditor(
                rtfData: $note.rtfData,
                plainText: $note.content,
                coordinator: coordinator,
                onTextChange: {
                    note.updatedAt = Date()
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "note.text")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue.opacity(0.5), .purple.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Select a Note")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.secondary)

            Text("Choose a note from the sidebar\nor create a new one")
                .font(.system(size: 13))
                .foregroundColor(.secondary.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.textBackgroundColor))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Note.self, inMemory: true)
}
