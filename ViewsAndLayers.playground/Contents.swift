//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport

let badgePath = UIBezierPath()
badgePath.move(to: CGPoint(x: 199.91, y: 41.87))
badgePath.addCurve(to: CGPoint(x: 194.36, y: 35.26), controlPoint1: CGPoint(x: 199.83, y: 38.56), controlPoint2: CGPoint(x: 197.55, y: 35.71))
badgePath.addCurve(to: CGPoint(x: 150.43, y: 23.99), controlPoint1: CGPoint(x: 179.48, y: 33.14), controlPoint2: CGPoint(x: 164.81, y: 29.45))
badgePath.addCurve(to: CGPoint(x: 103.19, y: 0.96), controlPoint1: CGPoint(x: 136.11, y: 18.55), controlPoint2: CGPoint(x: 120.27, y: 10.95))
badgePath.addCurve(to: CGPoint(x: 96.82, y: 0.96), controlPoint1: CGPoint(x: 101.02, y: -0.31), controlPoint2: CGPoint(x: 98.98, y: -0.32))
badgePath.addCurve(to: CGPoint(x: 49.7, y: 23.99), controlPoint1: CGPoint(x: 79.85, y: 10.95), controlPoint2: CGPoint(x: 64.13, y: 18.53))
badgePath.addCurve(to: CGPoint(x: 5.89, y: 35.26), controlPoint1: CGPoint(x: 35.31, y: 29.43), controlPoint2: CGPoint(x: 20.65, y: 33.14))
badgePath.addCurve(to: CGPoint(x: 0.1, y: 41.87), controlPoint1: CGPoint(x: 2.7, y: 35.71), controlPoint2: CGPoint(x: 0.46, y: 38.56))
badgePath.addCurve(to: CGPoint(x: 39.78, y: 196.11), controlPoint1: CGPoint(x: -1.31, y: 104.72), controlPoint2: CGPoint(x: 11.96, y: 156.14))
badgePath.addCurve(to: CGPoint(x: 96.82, y: 249.03), controlPoint1: CGPoint(x: 54.94, y: 217.88), controlPoint2: CGPoint(x: 73.91, y: 235.55))
badgePath.addCurve(to: CGPoint(x: 103.43, y: 249.03), controlPoint1: CGPoint(x: 98.59, y: 250.38), controlPoint2: CGPoint(x: 101.36, y: 250.27))
badgePath.addCurve(to: CGPoint(x: 160.23, y: 196.11), controlPoint1: CGPoint(x: 126.16, y: 235.33), controlPoint2: CGPoint(x: 145.11, y: 217.78))
badgePath.addCurve(to: CGPoint(x: 199.91, y: 41.87), controlPoint1: CGPoint(x: 188.09, y: 156.16), controlPoint2: CGPoint(x: 201.25, y: 104.72))
badgePath.close()


public class PseudoConnection: NSObject {
  public enum State {
    case disconnected
    case connecting
    case connected
  }
  private var state: State = .disconnected {
    didSet {
      stateChangeCallback(state)
    }
  }
  
  public typealias StateChange = ((State) -> ())
  private let stateChangeCallback: StateChange
  
  public init(stateChangeCallback: @escaping StateChange) {
    self.stateChangeCallback = stateChangeCallback
  }
  
  public func connect() {
    state = .connecting
    Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
      self?.state = .connected
    }
  }
  
  public func disconnect() {
    state = .disconnected
  }
  
  @objc public func toggle() {
    switch state {
    case .disconnected:
      connect()
    default:
      disconnect()
    }
  }
}

extension CGRect {
  init(centre: CGPoint, size: CGSize) {
    self.init(origin: centre.applying(CGAffineTransform(translationX: size.width / -2, y: size.height / -2)), size: size)
  }
  
  var centre: CGPoint {
    return CGPoint(x: midX, y: midY)
  }
  
  var size: CGSize {
    return CGSize(width: width, height: height)
  }
  
  var largestSquare: CGRect {
    let side = min(width, height)
    return CGRect(centre: centre, size: CGSize(width: side, height: side))
  }
}

extension CGSize {
  func rescale(_ scale: CGFloat) -> CGSize {
    return applying(CGAffineTransform(scaleX: scale, y: scale))
  }
}

extension CALayer {
  func applyPopShadow() {
    shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    shadowOffset = .zero
    shadowRadius = 1
    shadowOpacity = 0.1
  }
}

class ButtonView: UIView {
  private let buttonLayer = CALayer()
  private let innerCircle = CAShapeLayer()
  private let outerCircle = CAShapeLayer()
  private let greenBackground = CAShapeLayer()
  private let inProgressLayer = CAGradientLayer()
  private let badgeLayer = CAGradientLayer()
  
  enum State {
    case off
    case inProgress
    case on
  }
  
  public var state: State = .off {
    didSet {
      switch state {
      case .inProgress:
        showInProgress()
      case .on:
        showInProgress(false)
        animateToOn()
      case .off:
        showInProgress(false)
        animateToOff()
      }
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureLayers()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configureLayers()
  }
  
  private func configureLayers() {
    backgroundColor = #colorLiteral(red: 0.9600390625, green: 0.9600390625, blue: 0.9600390625, alpha: 1)
    
    buttonLayer.frame = bounds.largestSquare.offsetBy(dx: 0, dy: -20)
    
    outerCircle.path = UIBezierPath(ovalIn: CGRect(centre: buttonLayer.bounds.centre, size: buttonLayer.bounds.size.rescale(0.8))).cgPath
    innerCircle.path = UIBezierPath(ovalIn: CGRect(centre: buttonLayer.bounds.centre, size: buttonLayer.bounds.size.rescale(0.55))).cgPath
    greenBackground.path = UIBezierPath(ovalIn: CGRect(centre: buttonLayer.frame.centre, size: buttonLayer.bounds.size.rescale(0.55))).cgPath
    
    outerCircle.fillColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    innerCircle.fillColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    greenBackground.fillColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    
    innerCircle.shadowRadius = 15
    innerCircle.shadowOpacity = 0.1
    innerCircle.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    innerCircle.shadowOffset = CGSize(width: 15, height: 25)
    innerCircle.lineWidth = 3
    innerCircle.strokeColor = #colorLiteral(red: 0.6670270491, green: 0.6670270491, blue: 0.6670270491, alpha: 1)
    
    badgeLayer.colors = [#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), #colorLiteral(red: 0.8880859375, green: 0.8880859375, blue: 0.8880859375, alpha: 1)].map { $0.cgColor }
    badgeLayer.frame = layer.bounds
    
    outerCircle.applyPopShadow()
    badgeLayer.applyPopShadow()
    
    innerCircle.opacity = 1.0
    outerCircle.opacity = 0.4
    
    layer.addSublayer(badgeLayer)
    layer.addSublayer(greenBackground)
    
    buttonLayer.addSublayer(outerCircle)
    createInProgressLayer()
    buttonLayer.addSublayer(innerCircle)
    
    layer.addSublayer(buttonLayer)
    
    let badgeMask = CAShapeLayer()
    badgeMask.path = badgePath.cgPath
    let scale = layer.bounds.width / badgePath.bounds.width
    badgeMask.transform = CATransform3DMakeScale(scale, scale, 1)
    greenBackground.mask = badgeMask
    
    let badgeLayerMask = CAShapeLayer()
    badgeLayerMask.path = badgePath.cgPath
    badgeLayerMask.transform = CATransform3DMakeScale(scale, scale, 1)
    badgeLayer.mask = badgeLayerMask
  }
  
  private func createInProgressLayer() {
    inProgressLayer.colors = [#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), UIColor(white: 1, alpha: 0)].map{ $0.cgColor }
    inProgressLayer.locations = [0, 0.7].map { NSNumber(floatLiteral: $0) }
    inProgressLayer.frame = CGRect(centre: buttonLayer.bounds.centre, size: buttonLayer.bounds.size.rescale(0.58))

    let mask = CAShapeLayer()
    
    mask.path = UIBezierPath(ovalIn: CGRect(centre: inProgressLayer.bounds.centre, size: inProgressLayer.bounds.size)).cgPath
    mask.fillColor = UIColor.black.cgColor
    
    inProgressLayer.mask = mask
    inProgressLayer.isHidden = true
    
    buttonLayer.addSublayer(inProgressLayer)
  }
  
  @objc func animateToOn() {
    let path = UIBezierPath(ovalIn: CGRect(centre: bounds.centre, size: bounds.size.rescale(sqrt(2)))).cgPath
    let animation = CABasicAnimation(keyPath: "path")
    animation.fromValue = greenBackground.path
    animation.toValue = path
    animation.duration = 0.5
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    
    greenBackground.add(animation, forKey: "onAnimation")
    greenBackground.path = path
  }
  
  func animateToOff() {
    let animation = CABasicAnimation(keyPath: "path")
    animation.fromValue = greenBackground.path
    animation.toValue = UIBezierPath(ovalIn: CGRect(centre: buttonLayer.frame.centre, size: buttonLayer.bounds.size.rescale(0.55))).cgPath
    animation.duration = 0.5
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    
    greenBackground.add(animation, forKey: "offAnimation")
    greenBackground.path = UIBezierPath(ovalIn: CGRect(centre: buttonLayer.frame.centre, size: buttonLayer.bounds.size.rescale(0.55))).cgPath
  }
  
  func showInProgress(_ show: Bool = true) {
    if show {
      let animation = CABasicAnimation(keyPath: "transform.rotation.z")
      animation.fromValue = 0
      animation.toValue = 2 * Double.pi
      animation.duration = 2.0
      animation.repeatCount = .greatestFiniteMagnitude
      inProgressLayer.add(animation, forKey: "inProgressAnimation")
      inProgressLayer.isHidden = false
    } else {
      inProgressLayer.isHidden = true
      inProgressLayer.removeAnimation(forKey: "inProgressAnimation")
    }
  }
}


let aspectRatio = badgePath.bounds.width / badgePath.bounds.height
let button = ButtonView(frame: CGRect(x: 0, y: 0, width: 300, height: 300 / aspectRatio))

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = button


let connection = PseudoConnection { (state) in
  switch state {
  case .disconnected:
    button.state = .off
    print("Disconnected")
  case .connecting:
    button.state = .inProgress
    print("Connecting")
  case .connected:
    button.state = .on
    print("Connected")
  }
}

let gesture = UITapGestureRecognizer(target: connection, action: #selector(PseudoConnection.toggle))
button.addGestureRecognizer(gesture)

//: Icons made by <a href="https://www.fΩlaticon.com/authors/icon-works" title="Icon Works">Icon Works</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
