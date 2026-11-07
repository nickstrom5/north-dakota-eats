// North Dakota Eats icon concepts (2026-11-06), drawn in the shared Eats Ranked style (state-prompts/ICON-STYLE.md): one flat, level, centred
// food on big-sky blue #1E4F8C (the prompt's landscape palette), no backing shape, no text or texture, no bison, hawks, flag eagle or seal.
// Food hexes: bowl #FBF6EC, broth #F2D98A, dumplings #FFF8E7; fried dough #D9A04A, its edge #B5782E; crust #D9A04A, rhubarb #C2334D.
//   A  a bowl of knoephla, side elevation: potato dumplings over the broth line
//   B  a fleischkuechle, the golden half-moon of fried dough around seasoned beef
//   C  a slice of rhubarb pie with a lattice top
// Usage, from nd-eats/: swift scripts/icon-concepts.swift <out dir>   -> concept-{a,b,c}-1024.png
import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

func rgb(_ hex: UInt32) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 255) / 255, green: CGFloat((hex >> 8) & 255) / 255, blue: CGFloat(hex & 255) / 255, alpha: 1)
}
let SKY: UInt32 = 0x1E4F8C, BOWL: UInt32 = 0xFBF6EC, BROTH: UInt32 = 0xF2D98A, DUMPLING: UInt32 = 0xFFF8E7
let DOUGH: UInt32 = 0xD9A04A, EDGE: UInt32 = 0xB5782E, CRUST: UInt32 = 0xD9A04A, RHUBARB: UInt32 = 0xC2334D

func R(_ s: CGFloat, _ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ r: CGFloat) -> CGPath {
    CGPath(roundedRect: CGRect(x: x * s, y: y * s, width: w * s, height: h * s), cornerWidth: r * s, cornerHeight: r * s, transform: nil)
}

/// A: the knoephla bowl. CoreGraphics y-up. Identical to make-brand.swift's knoephla() and make-site.py's LOGO.
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

/// B: a fleischkuechle, the half-moon of fried dough.
func fleisch(_ c: CGContext, _ s: CGFloat) {
    c.setFillColor(rgb(EDGE))
    let p = CGMutablePath(); p.addArc(center: CGPoint(x: 0.5 * s, y: 0.32 * s), radius: 0.36 * s, startAngle: 0, endAngle: .pi, clockwise: false); p.closeSubpath()
    c.addPath(p); c.fillPath()
    c.setFillColor(rgb(DOUGH))
    let q = CGMutablePath(); q.addArc(center: CGPoint(x: 0.5 * s, y: 0.34 * s), radius: 0.31 * s, startAngle: 0, endAngle: .pi, clockwise: false); q.closeSubpath()
    c.addPath(q); c.fillPath()
}

/// C: a slice of rhubarb pie with a lattice top.
func pie(_ c: CGContext, _ s: CGFloat) {
    c.saveGState(); c.translateBy(x: 0, y: 0.045 * s); defer { c.restoreGState() }   // its mass sits low: lift it
    let tri = CGMutablePath()
    tri.move(to: CGPoint(x: 0.14 * s, y: 0.30 * s)); tri.addLine(to: CGPoint(x: 0.86 * s, y: 0.30 * s)); tri.addLine(to: CGPoint(x: 0.50 * s, y: 0.72 * s)); tri.closeSubpath()
    c.setFillColor(rgb(RHUBARB)); c.addPath(tri); c.fillPath()
    c.setFillColor(rgb(CRUST)); c.addPath(R(s, 0.14, 0.26, 0.72, 0.07, 0.03)); c.fillPath()        // the crust edge
    c.saveGState(); c.addPath(tri); c.clip()
    for x in [0.30, 0.44, 0.58] as [CGFloat] { c.fill(CGRect(x: x * s, y: 0.30 * s, width: 0.05 * s, height: 0.42 * s)) }
    c.fill(CGRect(x: 0.14 * s, y: 0.45 * s, width: 0.72 * s, height: 0.05 * s))
    c.restoreGState()
}

func render(_ n: Int, _ path: String, _ draw: (CGContext, CGFloat) -> Void) {
    let ctx = CGContext(data: nil, width: n, height: n, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    ctx.setShouldAntialias(true)
    ctx.setFillColor(rgb(SKY)); ctx.fill(CGRect(x: 0, y: 0, width: n, height: n))
    draw(ctx, CGFloat(n))
    let d = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(d, ctx.makeImage()!, nil)
    guard CGImageDestinationFinalize(d) else { fatalError("could not write \(path)") }
    print("wrote", path)
}
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "playbook/brand"
render(1024, out + "/concept-a-1024.png", knoephla)
render(1024, out + "/concept-b-1024.png", fleisch)
render(1024, out + "/concept-c-1024.png", pie)
