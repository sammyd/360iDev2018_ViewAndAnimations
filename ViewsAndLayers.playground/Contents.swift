//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport

extension CALayer {
  func applyPopShadow() {
    shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    shadowOffset = .zero
    shadowRadius = 1
    shadowOpacity = 0.1
  }
}

fileprivate extension CGFloat {
  static var outerCircleRatio: CGFloat = 0.8
  static var innerCircleRatio: CGFloat = 0.55
  static var inProgressRatio: CGFloat = 0.58
}

fileprivate extension Double {
  static var animationDuration: Double = 0.5
  static var inProgressPeriod: Double = 2.0
}

class ButtonView: UIView {
  private lazy var outerCircle: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.path = UIBezierPath(ovalIn: CGRect(centre: buttonLayer.bounds.centre, size: buttonLayer.bounds.size.rescale(CGFloat.outerCircleRatio))).cgPath
    layer.fillColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    layer.applyPopShadow()
    layer.opacity = 0.4
    return layer
  }()
  
  private lazy var innerCircle: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.path = UIBezierPath(ovalIn: CGRect(centre: buttonLayer.bounds.centre, size: buttonLayer.bounds.size.rescale(CGFloat.innerCircleRatio))).cgPath
    layer.fillColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    layer.shadowRadius = 15
    layer.shadowOpacity = 0.1
    layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    layer.shadowOffset = CGSize(width: 15, height: 25)
    layer.lineWidth = 3
    layer.strokeColor = #colorLiteral(red: 0.6670270491, green: 0.6670270491, blue: 0.6670270491, alpha: 1)
    layer.opacity = 1.0
    return layer
  }()
  
  private lazy var greenBackground: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.path = UIBezierPath(ovalIn: CGRect(centre: buttonLayer.frame.centre, size: buttonLayer.bounds.size.rescale(CGFloat.innerCircleRatio))).cgPath
    layer.fillColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    layer.mask = createBadgeMaskLayer()
    return layer
  }()
  
  private lazy var badgeLayer: CAGradientLayer = {
    let layer = CAGradientLayer()
    layer.colors = [#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), #colorLiteral(red: 0.8880859375, green: 0.8880859375, blue: 0.8880859375, alpha: 1)].map { $0.cgColor }
    layer.frame = self.layer.bounds
    layer.applyPopShadow()
    layer.mask = createBadgeMaskLayer()
    return layer
  }()
  
  private lazy var inProgressLayer: CAGradientLayer = {
    let layer = CAGradientLayer()
    layer.colors = [#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), UIColor(white: 1, alpha: 0)].map{ $0.cgColor }
    layer.locations = [0, 0.7].map { NSNumber(floatLiteral: $0) }
    layer.frame = CGRect(centre: buttonLayer.bounds.centre, size: buttonLayer.bounds.size.rescale(CGFloat.inProgressRatio))
    
    let mask = CAShapeLayer()
    
    mask.path = UIBezierPath(ovalIn: CGRect(centre: layer.bounds.centre, size: layer.bounds.size)).cgPath
    mask.fillColor = UIColor.black.cgColor
    layer.mask = mask
    layer.isHidden = true
    return layer
  }()
  
  private func createBadgeMaskLayer() -> CAShapeLayer {
    let scale = self.layer.bounds.width / UIBezierPath.badgePath.bounds.width
    let mask = CAShapeLayer()
    mask.path = UIBezierPath.badgePath.cgPath
    mask.transform = CATransform3DMakeScale(scale, scale, 1)
    return mask
  }
  
  private let buttonLayer = CALayer()
  
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
    buttonLayer.addSublayer(outerCircle)
    buttonLayer.addSublayer(inProgressLayer)
    buttonLayer.addSublayer(innerCircle)

    layer.addSublayer(badgeLayer)
    layer.addSublayer(greenBackground)
    layer.addSublayer(buttonLayer)
  }
  
  private func animateToOn() {
    let path = UIBezierPath(ovalIn: CGRect(centre: bounds.centre, size: bounds.size.rescale(sqrt(2)))).cgPath
    let animation = CABasicAnimation(keyPath: "path")
    animation.fromValue = greenBackground.path
    animation.toValue = path
    animation.duration = Double.animationDuration
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    
    greenBackground.add(animation, forKey: "onAnimation")
    greenBackground.path = path
  }
  
  private func animateToOff() {
    let animation = CABasicAnimation(keyPath: "path")
    animation.fromValue = greenBackground.path
    animation.toValue = UIBezierPath(ovalIn: CGRect(centre: buttonLayer.frame.centre, size: buttonLayer.bounds.size.rescale(CGFloat.innerCircleRatio))).cgPath
    animation.duration = Double.animationDuration
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    
    greenBackground.add(animation, forKey: "offAnimation")
    greenBackground.path = UIBezierPath(ovalIn: CGRect(centre: buttonLayer.frame.centre, size: buttonLayer.bounds.size.rescale(CGFloat.innerCircleRatio))).cgPath
  }
  
  private func showInProgress(_ show: Bool = true) {
    if show {
      let animation = CABasicAnimation(keyPath: "transform.rotation.z")
      animation.fromValue = 0
      animation.toValue = 2 * Double.pi
      animation.duration = Double.inProgressPeriod
      animation.repeatCount = .greatestFiniteMagnitude
      inProgressLayer.add(animation, forKey: "inProgressAnimation")
      inProgressLayer.isHidden = false
    } else {
      inProgressLayer.isHidden = true
      inProgressLayer.removeAnimation(forKey: "inProgressAnimation")
    }
  }
}


let aspectRatio = UIBezierPath.badgePath.bounds.width / UIBezierPath.badgePath.bounds.height
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
