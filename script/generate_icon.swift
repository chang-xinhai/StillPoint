import AppKit
import Foundation

let outputURL = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "Assets/AppIcon-1024.png")
try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)

let size = CGSize(width: 1024, height: 1024)
let image = NSImage(size: size)

image.lockFocus()

let rect = CGRect(origin: .zero, size: size)
let cornerRadius: CGFloat = 224
let path = NSBezierPath(roundedRect: rect.insetBy(dx: 64, dy: 64), xRadius: cornerRadius, yRadius: cornerRadius)

let gradient = NSGradient(colors: [
    NSColor(calibratedRed: 0.04, green: 0.45, blue: 1.0, alpha: 1),
    NSColor(calibratedRed: 0.02, green: 0.78, blue: 0.72, alpha: 1)
])!
gradient.draw(in: path, angle: -35)

NSColor.white.withAlphaComponent(0.18).setStroke()
path.lineWidth = 10
path.stroke()

let center = CGPoint(x: 512, y: 512)
let ring = NSBezierPath(ovalIn: CGRect(x: 252, y: 252, width: 520, height: 520))
NSColor.white.withAlphaComponent(0.92).setStroke()
ring.lineWidth = 54
ring.stroke()

let dot = NSBezierPath(ovalIn: CGRect(x: center.x - 54, y: center.y - 54, width: 108, height: 108))
NSColor.white.setFill()
dot.fill()

let pauseWidth: CGFloat = 54
let pauseHeight: CGFloat = 260
let pauseRadius: CGFloat = 27
let leftPause = NSBezierPath(
    roundedRect: CGRect(x: 390, y: 382, width: pauseWidth, height: pauseHeight),
    xRadius: pauseRadius,
    yRadius: pauseRadius
)
let rightPause = NSBezierPath(
    roundedRect: CGRect(x: 580, y: 382, width: pauseWidth, height: pauseHeight),
    xRadius: pauseRadius,
    yRadius: pauseRadius
)
NSColor.white.setFill()
leftPause.fill()
rightPause.fill()

let glint = NSBezierPath()
glint.move(to: CGPoint(x: 718, y: 754))
glint.line(to: CGPoint(x: 796, y: 784))
glint.line(to: CGPoint(x: 760, y: 706))
glint.close()
NSColor.white.withAlphaComponent(0.55).setFill()
glint.fill()

image.unlockFocus()

guard
    let tiff = image.tiffRepresentation,
    let bitmap = NSBitmapImageRep(data: tiff),
    let png = bitmap.representation(using: .png, properties: [:])
else {
    fputs("Failed to render StillPoint icon\n", stderr)
    exit(1)
}

try png.write(to: outputURL)
print(outputURL.path)

