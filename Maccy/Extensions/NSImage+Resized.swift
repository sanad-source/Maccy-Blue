import AppKit.NSImage

// Based on https://stackoverflow.com/questions/73062803/resizing-nsimage-keeping-aspect-ratio-reducing-the-image-size-while-trying-to-sc.
extension NSImage {
  /// Returns the pixel dimensions of the image.
  /// On Retina displays, this differs from `size` which returns logical points.
  var pixelSize: NSSize {
    if let bitmapRep = representations.first(where: { $0 is NSBitmapImageRep }) as? NSBitmapImageRep {
      return NSSize(width: CGFloat(bitmapRep.pixelsWide), height: CGFloat(bitmapRep.pixelsHigh))
    }
    // Fallback to logical size if no bitmap representation is available
    return size
  }
  func resized(to newSize: NSSize) -> NSImage {
    guard size.width > 0, size.height > 0, newSize.width > 0, newSize.height > 0 else {
      return self
    }

    let ratioX = newSize.width / size.width
    let ratioY = newSize.height / size.height
    let ratio = min(ratioX, ratioY)
    let newHeight = round(size.height * ratio)
    let newWidth = round(size.width * ratio)

    guard newWidth > 0, newHeight > 0, newWidth.isFinite, newHeight.isFinite else {
      return self
    }

    let targetSize = NSSize(width: newWidth, height: newHeight)

    // Don't attempt to size up if both dimensions already fit.
    if targetSize.height >= size.height && targetSize.width >= size.width {
      return self
    }

    let newImage = NSImage(size: targetSize)
    newImage.lockFocus()
    NSGraphicsContext.current?.imageInterpolation = .high
    self.draw(
      in: NSRect(origin: .zero, size: targetSize),
      from: NSRect.zero,
      operation: .copy,
      fraction: 1.0
    )
    newImage.unlockFocus()
    return newImage
  }
}
