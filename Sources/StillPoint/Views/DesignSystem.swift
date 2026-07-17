import SwiftUI

enum StillPointPalette {
    static let accent = Color(red: 0.20, green: 0.48, blue: 0.86)
    static let accentSoft = Color(red: 0.32, green: 0.58, blue: 0.90)
    static let warm = Color(red: 0.82, green: 0.52, blue: 0.22)
    static let danger = Color(red: 0.78, green: 0.30, blue: 0.28)
}

struct PressableButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.975 : 1)
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(
                reduceMotion ? nil : .easeOut(duration: 0.10),
                value: configuration.isPressed
            )
    }
}

struct PageHeader: View {
    var eyebrow: String
    var title: String
    var subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(eyebrow)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.system(size: 32, weight: .semibold, design: .default))
                .tracking(-0.7)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
            Text(subtitle)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct WorkspaceHeader<Trailing: View>: View {
    var eyebrow: String
    var title: String
    var subtitle: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text(eyebrow)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.system(size: 30, weight: .semibold))
                    .tracking(-0.65)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                Text(subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 20)

            trailing
        }
    }
}

extension WorkspaceHeader where Trailing == EmptyView {
    init(eyebrow: String, title: String, subtitle: String) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.trailing = EmptyView()
    }
}

struct SurfaceCard<Content: View>: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    var minHeight: CGFloat?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(reduceTransparency ? AnyShapeStyle(Color(nsColor: .controlBackgroundColor)) : AnyShapeStyle(.regularMaterial))
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(StillPointPalette.accent.opacity(0.022))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(.primary.opacity(0.085), lineWidth: 1)
        }
        .shadow(color: StillPointPalette.accent.opacity(0.055), radius: 28, x: 0, y: 16)
    }
}

struct PlainPanel<Content: View>: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    var minHeight: CGFloat?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(reduceTransparency ? Color(nsColor: .controlBackgroundColor) : Color(nsColor: .controlBackgroundColor).opacity(0.52))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.primary.opacity(0.075), lineWidth: 1)
        }
    }
}

struct MetricTile: View {
    var title: String
    var value: String
    var caption: String
    var systemImage: String
    var tint: Color = .accentColor

    var body: some View {
        SurfaceCard(minHeight: 118) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: systemImage)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(tint)
                        .frame(width: 18)
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Text(value)
                    .font(.system(size: 25, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.64)

                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct SummaryTile: View {
    var title: String
    var value: String
    var caption: String
    var systemImage: String
    var tint: Color

    var body: some View {
        PlainPanel(minHeight: 124) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: systemImage)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(tint)
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Text(value)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct PrimaryActionButton: View {
    var title: String
    var systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.callout.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(StillPointPalette.accent.gradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(.white.opacity(0.24), lineWidth: 1)
                }
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct QuietActionButton: View {
    var title: String
    var systemImage: String
    var tint: Color = .primary
    var role: ButtonRole?
    var action: () -> Void

    var body: some View {
        Button(role: role, action: action) {
            Label(title, systemImage: systemImage)
                .font(.callout.weight(.semibold))
                .foregroundStyle(tint)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(tint.opacity(0.085), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(tint.opacity(0.13), lineWidth: 1)
                }
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct StatusPill: View {
    var text: String
    var systemImage: String
    var tint: Color

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(tint.opacity(0.12), in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(tint.opacity(0.14), lineWidth: 1)
            }
    }
}

struct QuietDivider: View {
    var body: some View {
        Rectangle()
            .fill(.primary.opacity(0.08))
            .frame(height: 1)
    }
}

struct IconRoundel: View {
    var systemImage: String
    var tint: Color

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: 36, height: 36)
            .background(tint.opacity(0.11), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(tint.opacity(0.10), lineWidth: 1)
            }
    }
}

struct WatchStateButton: View {
    @Binding var isEnabled: Bool
    var language: AppLanguage

    var body: some View {
        Button {
            isEnabled.toggle()
        } label: {
            Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(isEnabled ? StillPointPalette.accent : .secondary)
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(isEnabled ? language.text("Ignore target", "忽略目标") : language.text("Enable target", "启用目标"))
        .accessibilityLabel(isEnabled ? language.text("Disable watched target", "停用监控目标") : language.text("Enable watched target", "启用监控目标"))
    }
}

struct HairlineDivider: View {
    var body: some View {
        Rectangle()
            .fill(.primary.opacity(0.10))
            .frame(height: 1)
    }
}

struct ProgressLine: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var value: Double
    var tint: Color = .cyan
    var marker: Double?

    var body: some View {
        GeometryReader { proxy in
            let clamped = min(max(value, 0), 1)
            let markerValue = marker.map { min(max($0, 0), 1) }

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.primary.opacity(0.09))

                Capsule()
                    .fill(tint.opacity(0.88))
                    .frame(width: max(6, proxy.size.width * clamped))

                if let markerValue {
                    Rectangle()
                        .fill(Color(nsColor: .windowBackgroundColor))
                        .frame(width: 2)
                        .offset(x: proxy.size.width * markerValue)
                    Rectangle()
                        .fill(StillPointPalette.accentSoft)
                        .frame(width: 2)
                        .offset(x: proxy.size.width * markerValue + 3)
                }
            }
        }
        .frame(height: 7)
        .animation(reduceMotion ? nil : .spring(response: 0.38, dampingFraction: 1), value: value)
        .accessibilityValue("\(Int(min(max(value, 0), 1) * 100)) percent")
    }
}

struct DataRow: View {
    var title: String
    var value: String
    var caption: String?

    init(_ title: String, value: String, caption: String? = nil) {
        self.title = title
        self.value = value
        self.caption = caption
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout.weight(.medium))
                if let caption {
                    Text(caption)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(value)
                .font(.callout.monospacedDigit().weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 9)
    }
}

struct SectionKicker: View {
    var title: String
    var systemImage: String?

    init(_ title: String, systemImage: String? = nil) {
        self.title = title
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(spacing: 7) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption.weight(.semibold))
            }
            Text(title)
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(.secondary)
    }
}

struct AppMark: View {
    var size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [StillPointPalette.accentSoft, StillPointPalette.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Circle()
                .stroke(.white.opacity(0.9), lineWidth: max(2, size * 0.08))
                .padding(size * 0.22)
            Circle()
                .fill(.white)
                .frame(width: size * 0.14, height: size * 0.14)
        }
        .frame(width: size, height: size)
        .shadow(color: StillPointPalette.accent.opacity(0.20), radius: size * 0.22, x: 0, y: size * 0.10)
    }
}
