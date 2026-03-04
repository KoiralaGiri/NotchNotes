import SwiftUI

/// A clean formatting toolbar for the rich text editor
struct FormattingToolbar: View {
    @Bindable var coordinator: RichTextCoordinator
    
    @State private var selectedTextColor: Color = .primary
    @State private var selectedHighlightColor: Color = .yellow
    
    var body: some View {
        HStack(spacing: 0) {
            // Text style toggles
            HStack(spacing: 1) {
                FormatButton(icon: "bold", isActive: coordinator.isBold) {
                    coordinator.toggleBold()
                }
                FormatButton(icon: "italic", isActive: coordinator.isItalic) {
                    coordinator.toggleItalic()
                }
                FormatButton(icon: "underline", isActive: coordinator.isUnderline) {
                    coordinator.toggleUnderline()
                }
                FormatButton(icon: "strikethrough", isActive: coordinator.isStrikethrough) {
                    coordinator.toggleStrikethrough()
                }
            }
            .padding(.horizontal, 4)
            
            ToolbarDivider()
            
            // Font size controls
            HStack(spacing: 2) {
                Button {
                    coordinator.changeFontSize(max(8, coordinator.fontSize - 1))
                } label: {
                    Image(systemName: "textformat.size.smaller")
                        .font(.system(size: 11))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                
                Text("\(Int(coordinator.fontSize))")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.7))
                    .frame(width: 24, alignment: .center)
                
                Button {
                    coordinator.changeFontSize(min(72, coordinator.fontSize + 1))
                } label: {
                    Image(systemName: "textformat.size.larger")
                        .font(.system(size: 11))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)
            
            ToolbarDivider()
            
            // Color controls
            HStack(spacing: 6) {
                // Text color
                ColorPicker(selection: $selectedTextColor, supportsOpacity: false) {
                    Label("Text Color", systemImage: "paintbrush.pointed")
                }
                .labelsHidden()
                .onChange(of: selectedTextColor) { _, newVal in
                    coordinator.applyTextColor(NSColor(newVal))
                }
                
                // Highlight
                ColorPicker(selection: $selectedHighlightColor, supportsOpacity: false) {
                    Label("Highlight", systemImage: "highlighter")
                }
                .labelsHidden()
                .onChange(of: selectedHighlightColor) { _, newVal in
                    coordinator.applyHighlightColor(NSColor(newVal))
                }
                
                // Clear highlight
                Button {
                    coordinator.applyHighlightColor(nil)
                } label: {
                    Image(systemName: "eraser")
                        .font(.system(size: 11))
                        .frame(width: 26, height: 26)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Remove highlight")
            }
            .padding(.horizontal, 4)
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Subviews

struct FormatButton: View {
    let icon: String
    var isActive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: isActive ? .semibold : .regular))
                .foregroundColor(isActive ? .accentColor : .primary.opacity(0.75))
                .frame(width: 28, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isActive ? Color.accentColor.opacity(0.12) : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
}

struct ToolbarDivider: View {
    var body: some View {
        Divider()
            .frame(height: 18)
            .padding(.horizontal, 6)
    }
}
