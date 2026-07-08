import SwiftUI

struct InterventionOverlayView: View {
    var context: InterventionContext
    var onAction: (InterventionAction) -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 22) {
                    HStack {
                        StatusPill(
                            text: context.isFocusLock ? "Deep Work Lock" : "Grace window ended",
                            systemImage: context.isFocusLock ? "lock.shield" : "pause.circle",
                            tint: context.isFocusLock ? .orange : .blue
                        )
                        Spacer()
                        Text(context.elapsedSeconds.shortDurationString)
                            .font(.callout.monospacedDigit().weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 9) {
                        Text("StillPoint")
                            .font(.system(size: 38, weight: .semibold))
                        Text("Are you still here for the reason you came?")
                            .font(.title2.weight(.semibold))
                            .multilineTextAlignment(.center)
                        Text("\(context.appName) has held focus long enough to check intent.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: 560)

                    QuietDivider()

                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            OverlayChoiceButton(
                                title: "Looking something up",
                                detail: "Purpose pass",
                                systemImage: "magnifyingglass",
                                tint: .blue
                            ) {
                                onAction(.purposePass)
                            }

                            OverlayChoiceButton(
                                title: "Intentional break",
                                detail: "Bounded pause",
                                systemImage: "cup.and.saucer",
                                tint: .purple
                            ) {
                                onAction(.intentionalBreak)
                            }
                        }

                        HStack(spacing: 10) {
                            OverlayChoiceButton(
                                title: "I drifted",
                                detail: "Close the feed",
                                systemImage: "xmark.circle",
                                tint: .red
                            ) {
                                onAction(.closeApp)
                            }

                            OverlayChoiceButton(
                                title: "Lock this",
                                detail: "Protect focus",
                                systemImage: "lock.shield",
                                tint: .orange
                            ) {
                                onAction(.startLock)
                            }
                        }
                    }
                }
                .padding(26)
            }
            .frame(width: 700)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(.white.opacity(0.14), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.34), radius: 30, x: 0, y: 18)
            .padding(40)
        }
        .preferredColorScheme(.dark)
    }
}

private struct OverlayChoiceButton: View {
    var title: String
    var detail: String
    var systemImage: String
    var tint: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 11) {
                IconRoundel(systemImage: systemImage, tint: tint)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(13)
            .frame(maxWidth: .infinity, minHeight: 72)
            .background(.primary.opacity(0.055), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(.primary.opacity(0.08), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

