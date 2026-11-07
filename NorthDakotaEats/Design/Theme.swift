import SwiftUI
import UIKit
import CoreText

/// North Dakota palette, a landscape one (provisional, 2026-11-06; Nick decides, playbook/05-naming.md), light only. Fans split between NDSU
/// (green and gold) and UND (green), so the colors come from the land (state-prompts/NORTH_DAKOTA_PROMPT.md): big-sky blue #1E4F8C (8.2:1 on
/// white) for titles, tint, the honors and oldest cards; Badlands scoria red #A63D2A (white on it 6.3:1) for the hand-checked guide cards and
/// chips; sunflower gold #E8B83A only as a pin, title-shadow and header fill under ink (#1A1A1A on it 9.9:1; as text on white it fails);
/// cream #F7F2E6 pages. The names `green`/`gold` are kept from Wisconsin Eats so the shared views read the same; here `green` is sky blue
/// and `gold` is scoria red.
enum Theme {
    static let green = Color(hex: 0x1E4F8C)      // big-sky blue: titles, tint, primary text accents
    static let green2 = Color(hex: 0x2A64A8)
    static let gold = Color(hex: 0xA63D2A)       // scoria red: card fills under white text, chips
    static let goldSoft = Color(hex: 0xF3DED8)   // soft scoria
    static let lime = Color(hex: 0xE8B83A)       // sunflower gold, fills only (hand-checked pins, the title shadow), under ink
    static let limeSoft = Color(hex: 0xFBEBC2)
    static let sand = Color(hex: 0xF7F2E6)       // the Home background, cream
    static let red = Color(hex: 0x1E4F8C)        // honors chips (blue)
    static let sandstone = Color(hex: 0x163B69)  // a darker blue accent
    static let teal = Color(hex: 0x7E2E1F)       // a darker scoria (8.9:1 on white)
    static let ink = Color(hex: 0x1A1A1A)
    static let ink2 = Color(hex: 0x2E3440)
    static let muted = Color(hex: 0x5B6270)
    static let surface = Color.white
    static let surface2 = Color(hex: 0xF0EADB)
    static let surface3 = Color(hex: 0xE4DCC8)
    static let rule = Color(hex: 0xE4DCC8)
    static let rule2 = Color(hex: 0xCBC1A8)
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255)
    }
}

/// A small uppercase label: "STONE CRAB", "1 MICHELIN STAR".
struct Chip: View {
    enum Style { case gold, green, red, plain, dashed }
    let text: String
    var style: Style = .plain

    var body: some View {
        Text(text.uppercased())
            .font(.caption2.weight(.bold))
            .tracking(0.4)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .foregroundStyle(style == .green || style == .red ? Color.white : style == .dashed ? Theme.muted : style == .gold ? Theme.ink : Theme.green)
            .background {
                RoundedRectangle(cornerRadius: 5).fill(style == .gold ? Theme.goldSoft : style == .green ? Theme.green : style == .red ? Theme.red
                                                       : style == .dashed ? .clear : Theme.surface2)
            }
            .overlay {
                if style == .dashed { RoundedRectangle(cornerRadius: 5).strokeBorder(Theme.rule2, style: StrokeStyle(lineWidth: 1, dash: [3, 2])) }
            }
            .accessibilityLabel(text)
    }
}

/// North Dakota Eats' lettering: the system face drawn compressed and heavy for titles and guide names (like a show poster), and the
/// system monospaced face for numbers, dates and small labels. No bundled fonts.
struct DisplayFont: ViewModifier {
    let size: CGFloat
    var weight: Font.Weight = .black
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    func body(content: Content) -> some View {
        content.font(.system(size: size * min(scale, 1.6), weight: weight).width(.compressed))
    }
}

/// Numbers, dates and small labels in the system monospaced face, scaled like DisplayFont.
struct MonoFont: ViewModifier {
    let size: CGFloat
    var weight: Font.Weight = .semibold
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    func body(content: Content) -> some View {
        content.font(.system(size: size * min(scale, 1.6), weight: weight, design: .monospaced))
    }
}

extension View {
    func displayFont(_ size: CGFloat, weight: Font.Weight = .black) -> some View {
        modifier(DisplayFont(size: size, weight: weight))
    }

    func monoFont(_ size: CGFloat, weight: Font.Weight = .semibold) -> some View {
        modifier(MonoFont(size: size, weight: weight))
    }
}

/// The header band: a prairie horizon with a grain elevator on it: sunflower-gold ground under an ink horizon line, the elevator a
/// sky-blue silhouette with its peaked head house.
struct Stripes: View {
    var height: CGFloat = 6

    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height, ground = h * 0.64
            ctx.fill(Path(CGRect(x: 0, y: ground, width: w, height: h - ground)), with: .color(Theme.lime))
            ctx.fill(Path(CGRect(x: 0, y: ground - 1, width: w, height: 1.5)), with: .color(Theme.ink))
            // the elevator: a tall bin with a peaked head house, and a lower annex beside it
            let x0 = w * 0.78, bw = h * 0.55
            var el = Path()
            el.addRect(CGRect(x: x0, y: h * 0.22, width: bw, height: ground - h * 0.22))
            el.move(to: CGPoint(x: x0 + bw * 0.15, y: h * 0.22)); el.addLine(to: CGPoint(x: x0 + bw * 0.5, y: 0))
            el.addLine(to: CGPoint(x: x0 + bw * 0.85, y: h * 0.22)); el.closeSubpath()
            el.addRect(CGRect(x: x0 + bw, y: h * 0.42, width: bw * 0.9, height: ground - h * 0.42))
            ctx.fill(el, with: .color(Theme.green))
        }
        .frame(height: height * 2.4)
        .accessibilityHidden(true)
    }
}

extension View {
    /// An inline navigation title in the display type. UINavigationBar.appearance() didn't reach every SwiftUI bar on iOS 27
    /// (the Map title went from compressed blue to plain black after a push and pop; place titles were always plain), so the
    /// title is our own view in the bar. The navigation title is still set, for the back button and VoiceOver.
    func inlineTitle(_ title: String) -> some View {
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title).displayFont(19, weight: .heavy).foregroundStyle(Theme.green)
                        .lineLimit(1).minimumScaleFactor(0.7)
                        .accessibilityAddTraits(.isHeader)
                }
            }
    }
}
