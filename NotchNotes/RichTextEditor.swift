import SwiftUI
import AppKit

/// Coordinator that bridges between the SwiftUI FormattingToolbar and the NSTextView
@Observable
class RichTextCoordinator {
    weak var textView: NSTextView?
    
    var isBold = false
    var isItalic = false
    var isUnderline = false
    var isStrikethrough = false
    var fontSize: CGFloat = 15
    var textColor: Color = .primary
    var highlightColor: Color = .clear
    
    func toggleBold() {
        guard let textView = textView else { return }
        let range = textView.selectedRange()
        guard range.length > 0 else {
            var attrs = textView.typingAttributes
            let currentFont = attrs[.font] as? NSFont ?? NSFont.systemFont(ofSize: fontSize)
            let fm = NSFontManager.shared
            let newFont: NSFont
            if fm.traits(of: currentFont).contains(.boldFontMask) {
                newFont = fm.convert(currentFont, toNotHaveTrait: .boldFontMask)
            } else {
                newFont = fm.convert(currentFont, toHaveTrait: .boldFontMask)
            }
            attrs[.font] = newFont
            textView.typingAttributes = attrs
            isBold.toggle()
            return
        }
        textView.textStorage?.beginEditing()
        textView.textStorage?.enumerateAttribute(.font, in: range) { value, attrRange, _ in
            let currentFont = value as? NSFont ?? NSFont.systemFont(ofSize: fontSize)
            let fm = NSFontManager.shared
            let newFont: NSFont
            if fm.traits(of: currentFont).contains(.boldFontMask) {
                newFont = fm.convert(currentFont, toNotHaveTrait: .boldFontMask)
            } else {
                newFont = fm.convert(currentFont, toHaveTrait: .boldFontMask)
            }
            textView.textStorage?.addAttribute(.font, value: newFont, range: attrRange)
        }
        textView.textStorage?.endEditing()
        textView.didChangeText()
        updateState()
    }
    
    func toggleItalic() {
        guard let textView = textView else { return }
        let range = textView.selectedRange()
        guard range.length > 0 else {
            var attrs = textView.typingAttributes
            let currentFont = attrs[.font] as? NSFont ?? NSFont.systemFont(ofSize: fontSize)
            let fm = NSFontManager.shared
            let newFont: NSFont
            if fm.traits(of: currentFont).contains(.italicFontMask) {
                newFont = fm.convert(currentFont, toNotHaveTrait: .italicFontMask)
            } else {
                newFont = fm.convert(currentFont, toHaveTrait: .italicFontMask)
            }
            attrs[.font] = newFont
            textView.typingAttributes = attrs
            isItalic.toggle()
            return
        }
        textView.textStorage?.beginEditing()
        textView.textStorage?.enumerateAttribute(.font, in: range) { value, attrRange, _ in
            let currentFont = value as? NSFont ?? NSFont.systemFont(ofSize: fontSize)
            let fm = NSFontManager.shared
            let newFont: NSFont
            if fm.traits(of: currentFont).contains(.italicFontMask) {
                newFont = fm.convert(currentFont, toNotHaveTrait: .italicFontMask)
            } else {
                newFont = fm.convert(currentFont, toHaveTrait: .italicFontMask)
            }
            textView.textStorage?.addAttribute(.font, value: newFont, range: attrRange)
        }
        textView.textStorage?.endEditing()
        textView.didChangeText()
        updateState()
    }
    
    func toggleUnderline() {
        guard let textView = textView else { return }
        let range = textView.selectedRange()
        guard range.length > 0 else {
            var attrs = textView.typingAttributes
            let current = attrs[.underlineStyle] as? Int ?? 0
            attrs[.underlineStyle] = current == 0 ? NSUnderlineStyle.single.rawValue : 0
            textView.typingAttributes = attrs
            isUnderline.toggle()
            return
        }
        textView.textStorage?.beginEditing()
        textView.textStorage?.enumerateAttribute(.underlineStyle, in: range) { value, attrRange, _ in
            let current = value as? Int ?? 0
            let newValue = current == 0 ? NSUnderlineStyle.single.rawValue : 0
            textView.textStorage?.addAttribute(.underlineStyle, value: newValue, range: attrRange)
        }
        textView.textStorage?.endEditing()
        textView.didChangeText()
        updateState()
    }
    
    func toggleStrikethrough() {
        guard let textView = textView else { return }
        let range = textView.selectedRange()
        guard range.length > 0 else {
            var attrs = textView.typingAttributes
            let current = attrs[.strikethroughStyle] as? Int ?? 0
            attrs[.strikethroughStyle] = current == 0 ? NSUnderlineStyle.single.rawValue : 0
            textView.typingAttributes = attrs
            isStrikethrough.toggle()
            return
        }
        textView.textStorage?.beginEditing()
        textView.textStorage?.enumerateAttribute(.strikethroughStyle, in: range) { value, attrRange, _ in
            let current = value as? Int ?? 0
            let newValue = current == 0 ? NSUnderlineStyle.single.rawValue : 0
            textView.textStorage?.addAttribute(.strikethroughStyle, value: newValue, range: attrRange)
        }
        textView.textStorage?.endEditing()
        textView.didChangeText()
        updateState()
    }
    
    func applyTextColor(_ color: NSColor) {
        guard let textView = textView else { return }
        let range = textView.selectedRange()
        guard range.length > 0 else {
            var attrs = textView.typingAttributes
            attrs[.foregroundColor] = color
            textView.typingAttributes = attrs
            return
        }
        textView.textStorage?.beginEditing()
        textView.textStorage?.addAttribute(.foregroundColor, value: color, range: range)
        textView.textStorage?.endEditing()
        textView.didChangeText()
    }
    
    func applyHighlightColor(_ color: NSColor?) {
        guard let textView = textView else { return }
        let range = textView.selectedRange()
        guard range.length > 0 else {
            var attrs = textView.typingAttributes
            if let color = color {
                attrs[.backgroundColor] = color
            } else {
                attrs.removeValue(forKey: .backgroundColor)
            }
            textView.typingAttributes = attrs
            return
        }
        textView.textStorage?.beginEditing()
        if let color = color {
            textView.textStorage?.addAttribute(.backgroundColor, value: color, range: range)
        } else {
            textView.textStorage?.removeAttribute(.backgroundColor, range: range)
        }
        textView.textStorage?.endEditing()
        textView.didChangeText()
    }
    
    func changeFontSize(_ newSize: CGFloat) {
        guard let textView = textView else { return }
        fontSize = newSize
        let range = textView.selectedRange()
        guard range.length > 0 else {
            var attrs = textView.typingAttributes
            let currentFont = attrs[.font] as? NSFont ?? NSFont.systemFont(ofSize: newSize)
            attrs[.font] = NSFontManager.shared.convert(currentFont, toSize: newSize)
            textView.typingAttributes = attrs
            return
        }
        textView.textStorage?.beginEditing()
        textView.textStorage?.enumerateAttribute(.font, in: range) { value, attrRange, _ in
            let currentFont = value as? NSFont ?? NSFont.systemFont(ofSize: newSize)
            let newFont = NSFontManager.shared.convert(currentFont, toSize: newSize)
            textView.textStorage?.addAttribute(.font, value: newFont, range: attrRange)
        }
        textView.textStorage?.endEditing()
        textView.didChangeText()
    }
    
    func updateState() {
        guard let textView = textView else { return }
        let attrs: [NSAttributedString.Key: Any]
        if textView.selectedRange().length > 0 {
            attrs = textView.textStorage?.attributes(at: textView.selectedRange().location, effectiveRange: nil) ?? [:]
        } else {
            attrs = textView.typingAttributes
        }
        
        let font = attrs[.font] as? NSFont ?? NSFont.systemFont(ofSize: 15)
        let traits = NSFontManager.shared.traits(of: font)
        isBold = traits.contains(.boldFontMask)
        isItalic = traits.contains(.italicFontMask)
        isUnderline = (attrs[.underlineStyle] as? Int ?? 0) != 0
        isStrikethrough = (attrs[.strikethroughStyle] as? Int ?? 0) != 0
        fontSize = font.pointSize
    }
}

/// NSViewRepresentable wrapping NSTextView for rich text editing.
/// Styled like a clean document editor — no borders, proper background, generous padding.
struct RichTextEditor: NSViewRepresentable {
    @Binding var rtfData: Data?
    @Binding var plainText: String
    var coordinator: RichTextCoordinator
    let onTextChange: () -> Void
    
    func makeCoordinator() -> Delegate {
        Delegate(parent: self)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        
        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }
        
        // Rich text configuration
        textView.isRichText = true
        textView.allowsUndo = true
        textView.usesFindPanel = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.importsGraphics = false
        textView.usesRuler = false
        textView.isRulerVisible = false
        textView.smartInsertDeleteEnabled = true
        textView.isAutomaticQuoteSubstitutionEnabled = true
        textView.isAutomaticDashSubstitutionEnabled = true
        
        // Document-like styling — clean background, generous padding
        textView.drawsBackground = true
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.textContainerInset = NSSize(width: 40, height: 30)
        textView.textContainer?.lineFragmentPadding = 8
        
        // Allow the text view to grow with content (like Google Docs)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.widthTracksTextView = true
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        
        // Default typing attributes — clean, readable font
        textView.typingAttributes = [
            .font: NSFont.systemFont(ofSize: 15, weight: .regular),
            .foregroundColor: NSColor.textColor,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 4
                return style
            }()
        ]
        
        textView.delegate = context.coordinator
        
        // Load existing content
        if let data = rtfData,
           let attrStr = NSAttributedString(rtf: data, documentAttributes: nil) {
            textView.textStorage?.setAttributedString(attrStr)
        } else if !plainText.isEmpty {
            textView.string = plainText
        }
        
        coordinator.textView = textView
        coordinator.updateState()
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if coordinator.textView !== textView {
            coordinator.textView = textView
        }
    }
    
    class Delegate: NSObject, NSTextViewDelegate {
        let parent: RichTextEditor
        
        init(parent: RichTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.plainText = textView.string
            let fullRange = NSRange(location: 0, length: textView.textStorage?.length ?? 0)
            parent.rtfData = textView.textStorage?.rtf(from: fullRange, documentAttributes: [:])
            parent.onTextChange()
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            parent.coordinator.updateState()
        }
    }
}
