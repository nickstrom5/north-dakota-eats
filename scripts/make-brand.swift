// North Dakota Eats brand (provisional, 2026-11-06; Nick picks the name, icon and palette): the app icon is concept A of
// scripts/icon-concepts.swift, a bowl of knoephla in side elevation (potato dumplings over the broth line), on big-sky blue; the shared Eats
// Ranked icon style, state-prompts/ICON-STYLE.md, no backing shape. No bison, hawks, flag eagle, great seal or team marks.
// Usage, from nd-eats/: swift scripts/make-brand.swift   -> NorthDakotaEats/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png,
// docs/ favicons and touch icons, docs/og.png. scripts/make-site.py draws the same mark as its inline SVG (LOGO): change both together.
import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

func rgb(_ hex: UInt32) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 255) / 255, green: CGFloat((hex >> 8) & 255) / 255, blue: CGFloat(hex & 255) / 255, alpha: 1)
}
let SKY: UInt32 = 0x1E4F8C, BOWL: UInt32 = 0xFBF6EC, BROTH: UInt32 = 0xF2D98A, DUMPLING: UInt32 = 0xFFF8E7
let CREAM: UInt32 = 0xF7F2E6, SUN: UInt32 = 0xE8B83A, INK: UInt32 = 0x1A1A1A

func R(_ s: CGFloat, _ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ r: CGFloat) -> CGPath {
    CGPath(roundedRect: CGRect(x: x * s, y: y * s, width: w * s, height: h * s), cornerWidth: r * s, cornerHeight: r * s, transform: nil)
}

/// A: the knoephla bowl. CoreGraphics y-up, s = canvas size. Identical to icon-concepts.swift's concept A.
func knoephla(_ c: CGContext, _ s: CGFloat) {
    c.setFillColor(rgb(BROTH)); c.addPath(R(s, 0.17, 0.57, 0.66, 0.06, 0.03)); c.fillPath()        // the broth line
    c.setFillColor(rgb(DUMPLING))
    for (x, y) in [(0.33, 0.64), (0.45, 0.66), (0.57, 0.64), (0.68, 0.65)] as [(CGFloat, CGFloat)] {   // dumplings riding the broth
        c.addEllipse(in: CGRect(x: (x - 0.055) * s, y: (y - 0.055) * s, width: 0.11 * s, height: 0.11 * s)); c.fillPath()
    }
    c.setFillColor(rgb(BOWL))
    let bowl = CGMutablePath()                                                                      // the bowl: the lower half of an ellipse
    bowl.addArc(center: .zero, radius: 1, startAngle: .pi, endAngle: 2 * .pi, clockwise: false,
                transform: CGAffineTransform(a: 0.36 * s, b: 0, c: 0, d: 0.29 * s, tx: 0.5 * s, ty: 0.59 * s))
    bowl.closeSubpath(); c.addPath(bowl); c.fillPath()
    c.addPath(R(s, 0.40, 0.26, 0.20, 0.05, 0.02)); c.fillPath()                                     // its foot
}

func render(_ n: Int, _ path: String, background: Bool) {
    let ctx = CGContext(data: nil, width: n, height: n, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: background ? CGImageAlphaInfo.noneSkipLast.rawValue : CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.setShouldAntialias(true)
    if background { ctx.setFillColor(rgb(SKY)); ctx.fill(CGRect(x: 0, y: 0, width: n, height: n)) }
    knoephla(ctx, CGFloat(n))
    let d = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(d, ctx.makeImage()!, nil)
    guard CGImageDestinationFinalize(d) else { fatalError("could not write \(path)") }
    print("wrote", path)
}
render(1024, "NorthDakotaEats/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png", background: true)
try? FileManager.default.createDirectory(atPath: "docs", withIntermediateDirectories: true)
for (n, name) in [(512, "icon-512.png"), (192, "icon-192.png"), (180, "apple-touch-icon.png"), (32, "favicon-32.png")] {
    render(n, "docs/" + name, background: true)
}

/// The share image (1200 x 630): big-sky blue, the bowl at the left, the name and tagline at the right, and the app's header band along the
/// bottom: a prairie horizon with a grain elevator, sunflower-gold ground under an ink line (Theme.swift's Stripes).
func og(_ path: String) {
    let W = 1200, H = 630
    let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    ctx.setShouldAntialias(true)
    ctx.setFillColor(rgb(SKY)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
    let band: CGFloat = 70, ground: CGFloat = 26
    ctx.setFillColor(rgb(CREAM)); ctx.fill(CGRect(x: 0, y: 0, width: CGFloat(W), height: band))
    ctx.setFillColor(rgb(SUN)); ctx.fill(CGRect(x: 0, y: 0, width: CGFloat(W), height: ground))
    ctx.setFillColor(rgb(INK)); ctx.fill(CGRect(x: 0, y: ground, width: CGFloat(W), height: 3))
    ctx.setFillColor(rgb(SKY))
    let x0: CGFloat = 930, bw: CGFloat = 26
    ctx.fill(CGRect(x: x0, y: ground + 3, width: bw, height: band - ground - 14))                    // the elevator's bin
    let roof = CGMutablePath(); roof.move(to: CGPoint(x: x0 + 3, y: band - 11)); roof.addLine(to: CGPoint(x: x0 + bw / 2, y: band - 2))
    roof.addLine(to: CGPoint(x: x0 + bw - 3, y: band - 11)); roof.closeSubpath(); ctx.addPath(roof); ctx.fillPath()   // its head house
    ctx.fill(CGRect(x: x0 + bw, y: ground + 3, width: 24, height: 20))                              // the annex
    ctx.saveGState(); ctx.translateBy(x: 40, y: 80); knoephla(ctx, 500); ctx.restoreGState()
    let ns = NSGraphicsContext(cgContext: ctx, flipped: false)
    NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = ns
    let title = NSFont(name: "AvenirNextCondensed-Heavy", size: 80) ?? NSFont.boldSystemFont(ofSize: 70)
    let sub = NSFont(name: "AvenirNextCondensed-DemiBold", size: 34) ?? NSFont.boldSystemFont(ofSize: 30)
    NSAttributedString(string: "NORTH DAKOTA", attributes: [.font: title, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 560, y: 380))
    NSAttributedString(string: "EATS", attributes: [.font: title, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 560, y: 296))
    NSAttributedString(string: "KNOEPHLA, STEAKS & WALLEYE", attributes: [.font: sub, .foregroundColor: NSColor(srgbRed: 0.910, green: 0.722, blue: 0.227, alpha: 1)]).draw(at: NSPoint(x: 564, y: 246))
    NSGraphicsContext.restoreGraphicsState()
    let d = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(d, ctx.makeImage()!, nil)
    guard CGImageDestinationFinalize(d) else { fatalError("could not write \(path)") }
    print("wrote", path)
}
og("docs/og.png")
