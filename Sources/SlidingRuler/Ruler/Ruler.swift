//
//  Ruler.swift
//
//  SlidingRuler
//
//  MIT License
//
//  Copyright (c) 2020 Pierre Tacchi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//


import SwiftUI

struct Ruler: View, Equatable {
    @Environment(\.slidingRulerStyle) private var style
    
    let cells: [RulerCell]
    let step: CGFloat
    let markOffset: CGFloat
    let bounds: ClosedRange<CGFloat>
    let formatter: NumberFormatter?
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(self.cells) { cell in
                self.style.makeCellBody(configuration: self.configuration(forCell: cell))
            }
        }
        .animation(nil)
    }
    
    private func configuration(forCell cell: RulerCell) -> SlidingRulerStyleConfiguation {
        return .init(mark: (cell.mark + markOffset) * step, bounds: bounds, step: step, formatter: formatter)
    }

    // Move the equality check into a view modifier or computed property
    func isEqual(to other: Ruler) -> Bool {
        // Create a view modifier to access environment values
        struct EnvironmentReader: ViewModifier {
            @Environment(\.slidingRulerStyle) private var style
            let perform: (Bool) -> Void
            
            func body(content: Content) -> some View {
                content.onAppear {
                    // Use the environment value here
                    let hasMarks = style.hasMarks
                    perform(hasMarks)
                }
            }
        }
        
        // Initial comparison without environment values
        let baseEqual = step == other.step && cells.count == other.cells.count
        
        // Return a closure that will be evaluated with the proper environment context
        return baseEqual && { hasMarks in
            !hasMarks || markOffset == other.markOffset
        }(style.hasMarks)
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.isEqual(to: rhs)
    }
}

struct Ruler_Previews: PreviewProvider {
    static var previews: some View {
        Ruler(cells: [.init(CGFloat(0))],
              step: 1.0, markOffset: 0, bounds: -1...1, formatter: nil)
    }
}
