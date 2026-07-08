import AppKit
import SwiftUI

@MainActor
final class OverlayInterventionPresenter {
    private var windows: [NSWindow] = []

    func show(context: InterventionContext, onAction: @escaping (InterventionAction) -> Void) {
        dismiss()

        let screens = NSScreen.screens.isEmpty ? [NSScreen.main].compactMap { $0 } : NSScreen.screens
        windows = screens.map { screen in
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            window.level = .screenSaver
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            window.contentView = NSHostingView(
                rootView: InterventionOverlayView(
                    context: context,
                    onAction: onAction
                )
            )
            window.makeKeyAndOrderFront(nil)
            return window
        }

        NSApp.activate(ignoringOtherApps: true)
    }

    func dismiss() {
        windows.forEach { $0.orderOut(nil) }
        windows.removeAll()
    }
}

