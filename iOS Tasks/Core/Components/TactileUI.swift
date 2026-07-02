import SwiftUI

// MARK: - Global Colors
let brutalistDark = Color(red: 15/255, green: 23/255, blue: 42/255) // #0F172A
let brutalistBg = Color(red: 248/255, green: 250/255, blue: 252/255) // #F8FAFC
let panelBg = Color(red: 241/255, green: 245/255, blue: 249/255) // #F1F5F9
let cautionYellow = Color(red: 250/255, green: 204/255, blue: 21/255) // #FACC15

// MARK: - Shared View Components

func tactilePixelBackground() -> some View {
    Canvas { context, size in
        let dotSize: CGFloat = 1
        let spacing: CGFloat = 16
        
        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(brutalistBg))
        
        for x in stride(from: 0, to: size.width, by: spacing) {
            for y in stride(from: 0, to: size.height, by: spacing) {
                let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                context.fill(Path(rect), with: .color(Color(red: 203/255, green: 213/255, blue: 225/255)))
            }
        }
    }
    .ignoresSafeArea()
}

func tactileCornerBrackets(color: Color) -> some View {
    GeometryReader { geo in
        Path { path in
            // TL
            path.move(to: CGPoint(x: 6, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 6))
            
            // TR
            path.move(to: CGPoint(x: geo.size.width - 6, y: 0))
            path.addLine(to: CGPoint(x: geo.size.width, y: 0))
            path.addLine(to: CGPoint(x: geo.size.width, y: 6))
            
            // BL
            path.move(to: CGPoint(x: 6, y: geo.size.height))
            path.addLine(to: CGPoint(x: 0, y: geo.size.height))
            path.addLine(to: CGPoint(x: 0, y: geo.size.height - 6))
            
            // BR
            path.move(to: CGPoint(x: geo.size.width - 6, y: geo.size.height))
            path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
            path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height - 6))
        }
        .stroke(color, lineWidth: 3)
    }
    .padding(-4) // Offset outwards
}

func tactileUIAccent(alignment: Alignment) -> some View {
    GeometryReader { geo in
        Path { path in
            if alignment == .topLeading {
                path.move(to: CGPoint(x: 8, y: 4))
                path.addLine(to: CGPoint(x: 4, y: 4))
                path.addLine(to: CGPoint(x: 4, y: 8))
            } else {
                path.move(to: CGPoint(x: geo.size.width - 8, y: geo.size.height - 4))
                path.addLine(to: CGPoint(x: geo.size.width - 4, y: geo.size.height - 4))
                path.addLine(to: CGPoint(x: geo.size.width - 4, y: geo.size.height - 8))
            }
        }
        .stroke(brutalistDark, lineWidth: 1.5)
    }
}
