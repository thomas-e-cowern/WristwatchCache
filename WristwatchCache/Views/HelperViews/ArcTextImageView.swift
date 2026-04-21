//
//  ArcTextImageView.swift
//  WristwatchCache
//
//  Created by Thomas Cowern on 4/4/26.
//

import SwiftUI
import CoreText

struct ArcTextImageView: View {
    let topText: String
    let bottomText: String
    let diameter: CGFloat
    let uiImage: UIImage?

    // Appearance
    var font: UIFont = .systemFont(ofSize: 16, weight: .semibold)
    var foregroundColor: Color = .white
    var backgroundColor: Color?
    var textRadiusInset: CGFloat = 12
    var imagePadding: CGFloat = 60          // shrinks the image to create a gap between image and text
    var characterSpacing: CGFloat = 0.15     // fraction of font size added between characters

    init(topText: String,
         bottomText: String,
         diameter: CGFloat,
         uiImage: UIImage? = nil) {
        self.topText = topText
        self.bottomText = bottomText
        self.diameter = diameter
        self.uiImage = uiImage
    }

    private var resolvedBackgroundColor: Color {
        backgroundColor ?? BrandView.brandColor(for: topText)
    }

    var body: some View {
        ZStack {
            // Outer ring (background for text)
            Circle()
                .fill(resolvedBackgroundColor)
                .frame(width: diameter, height: diameter)

            // Center content: user photo if available, otherwise BrandView
            if let ui = uiImage {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(width: diameter - imagePadding, height: diameter - imagePadding)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: diameter - imagePadding, height: diameter - imagePadding)
                    .overlay {
                        BrandView(brand: topText)
                            .scaleEffect((diameter - imagePadding) / 44 * 0.6)
                    }
                    .accessibilityHidden(true)
            }

            // Arc text drawn in Canvas
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let radius = diameter / 2 - textRadiusInset

                drawArcText(context: &context,
                            center: center,
                            radius: radius,
                            text: topText,
                            isTop: true)

                drawArcText(context: &context,
                            center: center,
                            radius: radius,
                            text: bottomText,
                            isTop: false)
            }
            .frame(width: diameter, height: diameter)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
        .frame(width: diameter, height: diameter)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(topText) \(bottomText)")
    }

    // MARK: - Drawing helper

    private func drawArcText(context: inout GraphicsContext,
                             center: CGPoint,
                             radius: CGFloat,
                             text: String,
                             isTop: Bool) {
        guard !text.isEmpty, radius > 0 else { return }

        let ctFont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        let attr: [NSAttributedString.Key: Any] = [.font: font]

        // Use font metrics for consistent vertical centering across all glyphs
        let ascent = CTFontGetAscent(ctFont)
        let descent = CTFontGetDescent(ctFont)
        let fontVerticalCenter = (ascent - descent) / 2

        // Measure each character's width individually
        let characters = Array(text)
        var charWidths: [CGFloat] = []
        for char in characters {
            let s = NSAttributedString(string: String(char), attributes: attr)
            let line = CTLineCreateWithAttributedString(s as CFAttributedString)
            charWidths.append(CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil)))
        }

        let spacing = font.pointSize * characterSpacing
        let totalWidth = charWidths.reduce(0, +) + spacing * CGFloat(max(characters.count - 1, 0))
        let totalAngle = totalWidth / radius

        // Top: centered at 12-o'clock, characters march left→right (increasing angle)
        // Bottom: centered at 6-o'clock, characters march left→right (decreasing angle)
        let baseAngle: CGFloat = isTop ? -.pi / 2 : .pi / 2
        let direction: CGFloat = isTop ? 1.0 : -1.0
        var angle = baseAngle - direction * totalAngle / 2

        let fill = GraphicsContext.Shading.color(foregroundColor)

        for (i, char) in characters.enumerated() {
            let halfArc = (charWidths[i] / 2) / radius
            angle += direction * halfArc

            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)

            // Top: ascenders face outward (rotation = angle + π/2)
            // Bottom: ascenders face inward so text reads normally (rotation = angle − π/2)
            let rotation = isTop ? angle + .pi / 2 : angle - .pi / 2

            // Get the glyph for this character
            var unichars = Array(String(char).utf16)
            var glyphBuf = [CGGlyph](repeating: 0, count: unichars.count)
            CTFontGetGlyphsForCharacters(ctFont, &unichars, &glyphBuf, unichars.count)

            if let path = CTFontCreatePathForGlyph(ctFont, glyphBuf[0], nil) {
                let bb = path.boundingBox
                var t = CGAffineTransform.identity
                // 1. Center glyph: horizontally by its own width, vertically by font metrics
                //    Using font-level ascent/descent keeps all characters on a consistent baseline
                t = t.translatedBy(x: -bb.midX, y: -fontVerticalCenter)
                // 2. Flip y-axis (CoreText y-up → Canvas y-down)
                t = t.concatenating(CGAffineTransform(scaleX: 1, y: -1))
                // 3. Rotate to follow the arc
                t = t.concatenating(CGAffineTransform(rotationAngle: rotation))
                // 4. Move to position on circle
                t = t.concatenating(CGAffineTransform(translationX: x, y: y))

                if let transformed = path.copy(using: &t) {
                    context.fill(Path(transformed), with: fill)
                }
            }

            angle += direction * halfArc
            if i < characters.count - 1 {
                angle += direction * (spacing / radius)
            }
        }
    }
}



#Preview {
    ArcTextImageView(topText: "Patek Philippe", bottomText: "Nautilus 5711/1A", diameter: 250)
}
