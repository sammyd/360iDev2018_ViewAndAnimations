//: # ButtonShield
//: A demo playground that demonstrates how to use Core Animation layers
//: to create a fun button, shamelessly stolen from ExpressVPN
//: > Icons made by [Icon Works](https://www.flaticon.com/authors/icon-works) from [www.flaticon.com](https://www.flaticon.com/) is licensed by [CC 3.0 BY](http://creativecommons.org/licenses/by/3.0/)

import UIKit
import PlaygroundSupport

//: ### Extensions to store constants

fileprivate extension CGFloat {
  static var outerCircleRatio: CGFloat = 0.8
  static var innerCircleRatio: CGFloat = 0.55
  static var inProgressRatio: CGFloat = 0.58
}

fileprivate extension Double {
  static var animationDuration: Double = 0.5
  static var inProgressPeriod: Double = 2.0
}

extension CALayer {
  func applyPopShadow() {
    shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    shadowOffset = .zero
    shadowRadius = 1
    shadowOpacity = 0.1
  }
}

//: ### The main ButtonView class

class ButtonView: UIView {
  private let buttonLayer = CALayer()
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
  
  private lazy var outerCircle: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.path = UIBezierPath(ovalIn: CGRect(centre: buttonLayer.bounds.centre, size: buttonLayer.bounds.size.rescale(CGFloat.outerCircleRatio))).cgPath
    layer.fillColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    layer.applyPopShadow()
    layer.opacity = 0.4
    return layer
  }()
  
  private lazy var greenBackground: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.path = UIBezierPath(ovalIn: CGRect(centre: bounds.centre, size: bounds.smallestContainingSquare.size.rescale(sqrt(2)))).cgPath
    layer.fillColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    layer.isHidden = true
    return layer
  }()

  
  
  
  
  enum State {
    case off
    case inProgress
    case on
  }
  
  public var state: State = .off {
    didSet {
      switch state {
      case .inProgress:
        break
      case .on:
        animateToOn()
      case .off:
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
    
    buttonLayer.frame = bounds.largestContainedSquare.offsetBy(dx: 0, dy: -20)
    buttonLayer.addSublayer(outerCircle)
    buttonLayer.addSublayer(innerCircle)
    
    layer.addSublayer(greenBackground)
    layer.addSublayer(buttonLayer)
  }
  
  private func animateToOn() {
    greenBackground.isHidden = false
  }
  
  private func animateToOff() {
    greenBackground.isHidden = true
  }
}

//: ### Present the button

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
