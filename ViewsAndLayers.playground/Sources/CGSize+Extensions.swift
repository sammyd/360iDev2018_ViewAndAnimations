import QuartzCore

public extension CGSize {
  public func rescale(_ scale: CGFloat) -> CGSize {
    return applying(CGAffineTransform(scaleX: scale, y: scale))
  }
}
