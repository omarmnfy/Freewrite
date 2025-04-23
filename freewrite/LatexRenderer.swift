import SwiftUI
import WebKit

struct LatexRenderer: NSViewRepresentable {
    let latex: String
    let colorScheme: ColorScheme
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        let textColor = colorScheme == .light ? "#333333" : "#FFFFFF"
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <script type="text/javascript" async
                src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/3.2.0/es5/tex-mml-chtml.js">
            </script>
            <style>
                body {
                    margin: 0;
                    padding: 0;
                    background: transparent;
                    color: \(textColor);
                }
                .math {
                    font-size: 1.2em;
                    display: inline-block;
                    vertical-align: middle;
                }
            </style>
        </head>
        <body>
            <div class="math">\(latex)</div>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}

struct LatexText: View {
    let text: String
    let colorScheme: ColorScheme
    @State private var latexRanges: [Range<String.Index>] = []
    @State private var textHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Base text
                Text(text)
                    .opacity(0) // Make it invisible but keep it for layout
                
                // LaTeX overlays
                ForEach(0..<latexRanges.count, id: \.self) { index in
                    let range = latexRanges[index]
                    let latex = String(text[range])
                        .replacingOccurrences(of: "$", with: "")
                    
                    // Calculate position based on text layout
                    let position = calculatePosition(for: range, in: text, geometry: geometry)
                    
                    LatexRenderer(latex: latex, colorScheme: colorScheme)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .position(x: position.x, y: position.y)
                }
            }
        }
        .onAppear {
            findLatexRanges()
        }
        .onChange(of: text) { _ in
            findLatexRanges()
        }
    }
    
    private func findLatexRanges() {
        var ranges: [Range<String.Index>] = []
        var startIndex = text.startIndex
        
        while let start = text[startIndex...].firstIndex(of: "$") {
            let afterStart = text.index(after: start)
            if let end = text[afterStart...].firstIndex(of: "$") {
                ranges.append(start..<text.index(after: end))
                startIndex = text.index(after: end)
            } else {
                break
            }
        }
        
        latexRanges = ranges
    }
    
    private func calculatePosition(for range: Range<String.Index>, in text: String, geometry: GeometryProxy) -> CGPoint {
        // This is a simplified position calculation
        // In a real implementation, you'd want to use NSTextView's layout manager
        // to get exact positions of text ranges
        let prefix = String(text[..<range.lowerBound])
        let lines = prefix.components(separatedBy: .newlines)
        let lineCount = lines.count
        let lastLine = lines.last ?? ""
        
        let x = geometry.size.width / 2
        let y = CGFloat(lineCount) * 20 // Approximate line height
        
        return CGPoint(x: x, y: y)
    }
} 