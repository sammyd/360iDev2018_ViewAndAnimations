import UIKit

public extension UIBezierPath {
  public static var badgePath: UIBezierPath {
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 199.91, y: 41.87))
    path.addCurve(to: CGPoint(x: 194.36, y: 35.26), controlPoint1: CGPoint(x: 199.83, y: 38.56), controlPoint2: CGPoint(x: 197.55, y: 35.71))
    path.addCurve(to: CGPoint(x: 150.43, y: 23.99), controlPoint1: CGPoint(x: 179.48, y: 33.14), controlPoint2: CGPoint(x: 164.81, y: 29.45))
    path.addCurve(to: CGPoint(x: 103.19, y: 0.96), controlPoint1: CGPoint(x: 136.11, y: 18.55), controlPoint2: CGPoint(x: 120.27, y: 10.95))
    path.addCurve(to: CGPoint(x: 96.82, y: 0.96), controlPoint1: CGPoint(x: 101.02, y: -0.31), controlPoint2: CGPoint(x: 98.98, y: -0.32))
    path.addCurve(to: CGPoint(x: 49.7, y: 23.99), controlPoint1: CGPoint(x: 79.85, y: 10.95), controlPoint2: CGPoint(x: 64.13, y: 18.53))
    path.addCurve(to: CGPoint(x: 5.89, y: 35.26), controlPoint1: CGPoint(x: 35.31, y: 29.43), controlPoint2: CGPoint(x: 20.65, y: 33.14))
    path.addCurve(to: CGPoint(x: 0.1, y: 41.87), controlPoint1: CGPoint(x: 2.7, y: 35.71), controlPoint2: CGPoint(x: 0.46, y: 38.56))
    path.addCurve(to: CGPoint(x: 39.78, y: 196.11), controlPoint1: CGPoint(x: -1.31, y: 104.72), controlPoint2: CGPoint(x: 11.96, y: 156.14))
    path.addCurve(to: CGPoint(x: 96.82, y: 249.03), controlPoint1: CGPoint(x: 54.94, y: 217.88), controlPoint2: CGPoint(x: 73.91, y: 235.55))
    path.addCurve(to: CGPoint(x: 103.43, y: 249.03), controlPoint1: CGPoint(x: 98.59, y: 250.38), controlPoint2: CGPoint(x: 101.36, y: 250.27))
    path.addCurve(to: CGPoint(x: 160.23, y: 196.11), controlPoint1: CGPoint(x: 126.16, y: 235.33), controlPoint2: CGPoint(x: 145.11, y: 217.78))
    path.addCurve(to: CGPoint(x: 199.91, y: 41.87), controlPoint1: CGPoint(x: 188.09, y: 156.16), controlPoint2: CGPoint(x: 201.25, y: 104.72))
    path.close()
    return path
  }
}


