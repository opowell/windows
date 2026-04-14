import AppKit

// MARK: - Custom Drawing View

/// A view that maintains a list of drawable shapes and renders them.
class CanvasView: NSView {

    enum Shape {
        case line       // A 2-pt straight line
        case circle
        case rectangle
    }

    private var shapes: [Shape] = []

    func addShape(_ shape: Shape) {
        shapes.append(shape)
        needsDisplay = true
    }

    override var isFlipped: Bool { true }   // top-left origin keeps layout intuitive

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Fill background with white so shapes are always visible
        NSColor.white.setFill()
        bounds.fill()

        let inset: CGFloat = 30
        let usable = bounds.insetBy(dx: inset, dy: inset)

        // Palette of colours so overlapping shapes are distinguishable
        let palette: [NSColor] = [
            .systemBlue, .systemRed, .systemGreen,
            .systemOrange, .systemPurple, .systemTeal
        ]

        for (index, shape) in shapes.enumerated() {

            let color = palette[index % palette.count]
            color.setStroke()
            color.withAlphaComponent(0.15).setFill()

            // Distribute shapes vertically inside the usable rect
            let slotHeight = usable.height / max(CGFloat(shapes.count), 1)
            let slotY      = usable.minY + slotHeight * CGFloat(index)
            let slotRect   = NSRect(x: usable.minX,
                                    y: slotY + 8,
                                    width: usable.width,
                                    height: slotHeight - 16)

            switch shape {

            case .line:
                let path = NSBezierPath()
                path.lineWidth = 2
                path.move(to: NSPoint(x: slotRect.minX, y: slotRect.midY))
                path.line(to: NSPoint(x: slotRect.maxX, y: slotRect.midY))
                path.stroke()

            case .circle:
                let side = min(slotRect.width, slotRect.height)
                let circleRect = NSRect(
                    x: slotRect.midX - side / 2,
                    y: slotRect.midY - side / 2,
                    width: side,
                    height: side
                )
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = 2
                path.fill()
                path.stroke()

            case .rectangle:
                let rectPath = NSBezierPath(rect: slotRect)
                rectPath.lineWidth = 2
                rectPath.fill()
                rectPath.stroke()
            }
        }
    }
}

// MARK: - Application Delegate

class AppDelegate: NSObject, NSApplicationDelegate {

    /// Every window we create is tracked here so we can delete the most recent one.
    private var managedWindows: [NSWindow] = []
    private var windowCounter = 0

    // ------------------------------------------------------------------ //
    // MARK: Lifecycle
    // ------------------------------------------------------------------ //

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildMenuBar()
    }

    /// Keep the app alive even when all windows are closed (standard macOS behaviour
    /// for document-based or utility apps).
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    // ------------------------------------------------------------------ //
    // MARK: Menu Construction
    // ------------------------------------------------------------------ //

    private func buildMenuBar() {
        let mainMenu = NSMenu()

        // — App menu (required for Quit, Hide, etc.) —
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "About Windows",
                        action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
                        keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Quit Windows",
                        action: #selector(NSApplication.terminate(_:)),
                        keyEquivalent: "q")
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        // — "Windows" menu —
        let windowsMenuItem = NSMenuItem()
        let windowsMenu = NSMenu(title: "Windows")
        windowsMenu.addItem(withTitle: "Create New Window",
                            action: #selector(createNewWindow),
                            keyEquivalent: "n")
        windowsMenu.addItem(withTitle: "Delete Window",
                            action: #selector(deleteWindow),
                            keyEquivalent: "w")
        windowsMenuItem.submenu = windowsMenu
        mainMenu.addItem(windowsMenuItem)

        // — "Lines" menu —
        let linesMenuItem = NSMenuItem()
        let linesMenu = NSMenu(title: "Lines")
        linesMenu.addItem(withTitle: "2 pt Line",
                          action: #selector(addLine),
                          keyEquivalent: "1")
        linesMenu.addItem(withTitle: "Circle",
                          action: #selector(addCircle),
                          keyEquivalent: "2")
        linesMenu.addItem(withTitle: "Rectangle",
                          action: #selector(addRectangle),
                          keyEquivalent: "3")
        linesMenuItem.submenu = linesMenu
        mainMenu.addItem(linesMenuItem)

        NSApplication.shared.mainMenu = mainMenu
    }

    // ------------------------------------------------------------------ //
    // MARK: Window Actions
    // ------------------------------------------------------------------ //

    @objc private func createNewWindow() {
        windowCounter += 1

        let frame = cascadedFrame(for: windowCounter)
        let window = NSWindow(
            contentRect: frame,
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Window \(windowCounter)"
        window.contentView = CanvasView(frame: frame)
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)

        managedWindows.append(window)
    }

    @objc private func deleteWindow() {
        guard let window = managedWindows.popLast() else {
            let alert = NSAlert()
            alert.messageText = "No Windows"
            alert.informativeText = "There are no open windows to delete."
            alert.alertStyle = .informational
            alert.runModal()
            return
        }
        window.close()
    }

    // ------------------------------------------------------------------ //
    // MARK: Drawing Actions
    // ------------------------------------------------------------------ //

    @objc private func addLine()      { addShapeToFrontWindow(.line) }
    @objc private func addCircle()    { addShapeToFrontWindow(.circle) }
    @objc private func addRectangle() { addShapeToFrontWindow(.rectangle) }

    private func addShapeToFrontWindow(_ shape: CanvasView.Shape) {
        // Prefer the key (frontmost) managed window
        let target = managedWindows.first(where: { $0.isKeyWindow })
                  ?? managedWindows.last

        guard let canvas = target?.contentView as? CanvasView else {
            let alert = NSAlert()
            alert.messageText = "No Window Available"
            alert.informativeText = "Please create a window first (Windows → Create New Window)."
            alert.alertStyle = .informational
            alert.runModal()
            return
        }
        canvas.addShape(shape)
    }

    // ------------------------------------------------------------------ //
    // MARK: Helpers
    // ------------------------------------------------------------------ //

    /// Returns a slightly offset frame for each successive window so they cascade.
    private func cascadedFrame(for index: Int) -> NSRect {
        let baseX: CGFloat = 200
        let baseY: CGFloat = 200
        let offset: CGFloat = 30 * CGFloat((index - 1) % 10)
        return NSRect(x: baseX + offset,
                      y: baseY - offset,
                      width: 520,
                      height: 400)
    }
}

// MARK: - Entry Point

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.activate(ignoringOtherApps: true)
app.run()