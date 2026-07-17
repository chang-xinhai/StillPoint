import SwiftUI

struct InterventionOverlayView: View {
    var context: InterventionContext
    var onAction: (InterventionAction) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.56)
                .ignoresSafeArea()

            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(reduceTransparency ? 0 : 0.32)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    StatusPill(
                        text: context.isFocusLock
                            ? context.language.text("Deep Work checkpoint", "专注锁检查点")
                            : context.language.text("A moment to choose", "停一下，再选择"),
                        systemImage: context.isFocusLock ? "lock.shield" : "pause.fill",
                        tint: context.isFocusLock ? StillPointPalette.warm : StillPointPalette.accent
                    )

                    Spacer()

                    Text(context.elapsedSeconds.shortDurationString)
                        .font(.callout.monospacedDigit().weight(.medium))
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(context.language.text(
                        "Is this still what you came for?",
                        "你还在做刚才想做的事吗？"
                    ))
                    .font(.system(size: 32, weight: .semibold))
                    .tracking(-0.7)
                    .fixedSize(horizontal: false, vertical: true)

                    Text(context.language.text(
                        "You’ve been in (context.appName) long enough for the visit to become automatic. Nothing is wrong — choose what happens next.",
                        "你已经在 (context.appName) 停留了一段时间，最初的访问可能正在变成无意识滑动。没关系，重新选择下一步。"
                    ))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                }

                Button {
                    onAction(.closeApp)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.language.text("Return to what I was doing", "回到刚才在做的事"))
                                .font(.headline)
                            Text(context.language.text("Close this feed", "关闭这个信息流"))
                                .font(.caption)
                                .opacity(0.78)
                        }
                        Spacer()
                        Image(systemName: "return")
                            .foregroundStyle(.white.opacity(0.68))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, minHeight: 62)
                    .background(StillPointPalette.accent.gradient, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .strokeBorder(.white.opacity(0.20), lineWidth: 1)
                    }
                }
                .buttonStyle(PressableButtonStyle())
                .keyboardShortcut(.defaultAction)

                VStack(alignment: .leading, spacing: 10) {
                    Text(context.language.text("Or continue deliberately", "或者，有意识地继续"))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        OverlayChoiceButton(
                            title: context.language.text("Look something up", "查完一件事"),
                            detail: context.language.text("Brief purpose pass", "短时查找通行"),
                            systemImage: "magnifyingglass"
                        ) {
                            onAction(.purposePass)
                        }

                        OverlayChoiceButton(
                            title: context.language.text("Take an intentional break", "有意休息一下"),
                            detail: context.language.text("A bounded pause", "有边界的暂停"),
                            systemImage: "cup.and.saucer"
                        ) {
                            onAction(.intentionalBreak)
                        }
                    }

                    Button {
                        onAction(.startLock)
                    } label: {
                        Label(
                            context.language.text("Start Deep Work Lock after closing", "关闭后开启专注锁"),
                            systemImage: "lock.shield"
                        )
                        .font(.callout.weight(.medium))
                        .foregroundStyle(context.isFocusLock ? .secondary : StillPointPalette.warm)
                        .frame(maxWidth: .infinity, minHeight: 34)
                    }
                    .buttonStyle(PressableButtonStyle())
                    .disabled(context.isFocusLock)
                }
            }
            .padding(28)
            .frame(width: 650)
            .background {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(reduceTransparency ? AnyShapeStyle(Color(nsColor: .windowBackgroundColor)) : AnyShapeStyle(.ultraThickMaterial))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(.white.opacity(0.16), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.32), radius: 42, x: 0, y: 24)
            .scaleEffect(appeared || reduceMotion ? 1 : 0.965)
            .opacity(appeared ? 1 : 0)
            .padding(40)
        }
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.18) : .spring(response: 0.38, dampingFraction: 0.90)) {
                appeared = true
            }
        }
    }
}

private struct OverlayChoiceButton: View {
    var title: String
    var detail: String
    var systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 11) {
                Image(systemName: systemImage)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(StillPointPalette.accent)
                    .frame(width: 30, height: 30)
                    .background(StillPointPalette.accent.opacity(0.09), in: RoundedRectangle(cornerRadius: 9, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.callout.weight(.semibold))
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 4)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 66)
            .background(.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .strokeBorder(.primary.opacity(0.075), lineWidth: 1)
            }
        }
        .buttonStyle(PressableButtonStyle())
    }
}
