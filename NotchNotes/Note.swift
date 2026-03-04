import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID
    var content: String
    var rtfData: Data?
    var isPinned: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(content: String = "", isPinned: Bool = false) {
        self.id = UUID()
        self.content = content
        self.rtfData = nil
        self.isPinned = isPinned
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// Title derived from the first line of plaintext content
    var title: String {
        let firstLine = content.split(separator: "\n").first.map(String.init) ?? ""
        return firstLine.isEmpty ? "New Note" : firstLine
    }
    
    /// Short preview from the second line onwards
    var preview: String {
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
        if lines.count > 1 {
            return lines.dropFirst().joined(separator: " ").trimmingCharacters(in: .whitespaces)
        }
        return ""
    }
}
