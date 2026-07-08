import AppKit
import SwiftUI

@MainActor
final class StatusItemController: NSObject {
    static let shared = StatusItemController()

    private var statusItem: NSStatusItem?
    private var menu: NSMenu?
    private weak var model: AppModel?
    private var openControlCenterAction: (() -> Void)?

    private override init() {
        super.init()
    }

    func install(model: AppModel) {
        self.model = model

        if statusItem == nil {
            let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
            item.isVisible = true
            statusItem = item
            configureButton()
        }

        rebuildMenu()
    }

    func setOpenControlCenterAction(_ action: @escaping () -> Void) {
        openControlCenterAction = action
        rebuildMenu()
    }

    private func configureButton() {
        guard let button = statusItem?.button else { return }

        button.image = statusImage()
        button.image?.isTemplate = true
        button.title = ""
        button.imagePosition = .imageLeading
        button.toolTip = "StillPoint"
        button.target = self
        button.action = #selector(showMenu(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    @objc private func showMenu(_ sender: Any?) {
        rebuildMenu()
        guard let menu, let button = statusItem?.button else { return }
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height + 2), in: button)
    }

    private func rebuildMenu() {
        guard let model else { return }

        let menu = menu ?? NSMenu()
        menu.autoenablesItems = false
        menu.removeAllItems()

        let hostingView = NSHostingView(
            rootView: MenuBarView(
                model: model,
                openControlCenter: { [weak self] in
                    self?.menu?.cancelTracking()
                    self?.openControlCenterAction?()
                }
            )
            .frame(width: 382)
        )
        hostingView.frame = NSRect(x: 0, y: 0, width: 382, height: 494)

        let item = NSMenuItem()
        item.view = hostingView
        menu.addItem(item)

        self.menu = menu
        statusItem?.menu = nil
    }

    private func statusImage() -> NSImage? {
        let preferredNames = ["scope", "smallcircle.filled.circle", "target"]
        for name in preferredNames {
            if let image = NSImage(systemSymbolName: name, accessibilityDescription: "StillPoint") {
                return image
            }
        }
        return nil
    }
}
