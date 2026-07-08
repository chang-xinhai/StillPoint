import SwiftUI

struct InterventionOverlayView: View {
    var context: InterventionContext
    var onAction: (InterventionAction) -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.88)
                .ignoresSafeArea()

            VStack(spacing: 26) {
                Image(systemName: context.isFocusLock ? "lock.shield.fill" : "pause.circle.fill")
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(.white)

                VStack(spacing: 10) {
                    Text("StillPoint")
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("You have been in \(context.appName) for \(context.elapsedSeconds.shortDurationString).")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.76))
                    Text("Are you still here for the reason you came?")
                        .font(.title.weight(.medium))
                        .foregroundStyle(.white)
                }

                Text(context.triggerReason)
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.7))

                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        actionButton("Looking something up", detail: "3 min", icon: "magnifyingglass") {
                            onAction(.purposePass)
                        }
                        actionButton("Intentional break", detail: "5 min", icon: "cup.and.saucer") {
                            onAction(.intentionalBreak)
                        }
                    }
                    HStack(spacing: 12) {
                        actionButton("I drifted", detail: "Close it", icon: "xmark.circle") {
                            onAction(.closeApp)
                        }
                        actionButton("Lock this", detail: "Until focus ends", icon: "lock.shield") {
                            onAction(.startLock)
                        }
                    }
                }
                .frame(maxWidth: 760)
            }
            .padding(40)
        }
    }

    private func actionButton(
        _ title: String,
        detail: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    Text(detail)
                        .font(.callout)
                        .opacity(0.72)
                }
                Spacer()
            }
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity, minHeight: 72)
            .background(.white.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

