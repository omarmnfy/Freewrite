import SwiftUI

struct MarkdownText: View {
    let text: String
    let colorScheme: ColorScheme
    
    var body: some View {
        Text(attributedString)
            .foregroundColor(colorScheme == .light ? Color(red: 0.20, green: 0.20, blue: 0.20) : Color(red: 0.9, green: 0.9, blue: 0.9))
    }
    
    private var attributedString: AttributedString {
        var attributedString = AttributedString(text)
        
        // Bold
        if let regex = try? NSRegularExpression(pattern: "\\*\\*(.*?)\\*\\*") {
            let range = NSRange(location: 0, length: text.utf16.count)
            let matches = regex.matches(in: text, range: range)
            
            for match in matches.reversed() {
                if let range = Range(match.range(at: 0), in: text) {
                    let startIndex = range.lowerBound
                    let endIndex = range.upperBound
                    attributedString[startIndex..<endIndex].font = .boldSystemFont(ofSize: 16)
                }
            }
        }
        
        // Italic
        if let regex = try? NSRegularExpression(pattern: "\\*(.*?)\\*") {
            let range = NSRange(location: 0, length: text.utf16.count)
            let matches = regex.matches(in: text, range: range)
            
            for match in matches.reversed() {
                if let range = Range(match.range(at: 1), in: text) {
                    let startIndex = attributedString.index(attributedString.startIndex, offsetBy: match.range(at: 0).location)
                    let endIndex = attributedString.index(startIndex, offsetBy: match.range(at: 0).length)
                    attributedString[startIndex..<endIndex].font = .italicSystemFont(ofSize: 16)
                }
            }
        }
        
        // Headers
        if let regex = try? NSRegularExpression(pattern: "^#+\\s+(.*?)$", options: .anchorsMatchLines) {
            let range = NSRange(location: 0, length: text.utf16.count)
            let matches = regex.matches(in: text, range: range)
            
            for match in matches.reversed() {
                if let range = Range(match.range(at: 0), in: text) {
                    let startIndex = range.lowerBound
                    let endIndex = range.upperBound
                    attributedString[startIndex..<endIndex].font = .boldSystemFont(ofSize: 20)
                }
            }
        }
        
        // Lists
        if let regex = try? NSRegularExpression(pattern: "^[-*+]\\s+(.*?)$", options: .anchorsMatchLines) {
            let range = NSRange(location: 0, length: text.utf16.count)
            let matches = regex.matches(in: text, range: range)
            
            for match in matches.reversed() {
                if let range = Range(match.range(at: 0), in: text) {
                    let startIndex = attributedString.index(attributedString.startIndex, offsetBy: match.range(at: 0).location)
                    let endIndex = attributedString.index(startIndex, offsetBy: match.range(at: 0).length)
                    attributedString[startIndex..<endIndex].font = .systemFont(ofSize: 16)
                }
            }
        }
        
        return attributedString
    }
}