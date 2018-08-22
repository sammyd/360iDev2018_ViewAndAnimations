//: A UIKit based Playground for presenting user interface
  
import UIKit
import MapKit
import PlaygroundSupport

extension UIView {
  func round(corners: UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: bounds,
                            byRoundingCorners: corners,
                            cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    layer.mask = mask
  }
}

final class SwipeUpTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
  private let vcToPresent: UIViewController
  private weak var presentingVC: UIViewController?
  
  init(viewControllerToPresent: UIViewController, presentingViewController: UIViewController) {
    self.vcToPresent = viewControllerToPresent
    self.presentingVC = presentingViewController
  }
  
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    return SwipeUpPresentationController(presentedViewController: vcToPresent, presenting: presentingVC)
  }
}


final class SwipeUpPresentationController: UIPresentationController {
  
  enum Position {
    case open
    case partial
    case closed
    
    var relativeHeight: CGFloat {
      switch self {
      case .open: return 1.0
      case .partial: return 0.6
      case .closed: return 0.1
      }
    }
    
    
    
    func origin(for height: CGFloat) -> CGPoint {
      return CGPoint(x: 0, y: height * (1 - relativeHeight))
    }
  }
  private var animator: UIViewPropertyAnimator?
  private let springTiming = UISpringTimingParameters(dampingRatio: 0.5, initialVelocity: CGVector(dx: 0, dy: 1))
  
  private var currentPosition: Position = .closed
  private var maxFrame: CGRect {
    guard let window = presentingViewController.view.window
      else {
      fatalError("Need access to the window")
    }
    return CGRect(x: 0, y: 0, width: window.bounds.width, height: window.bounds.height + window.safeAreaInsets.bottom)
  }
  
  override var frameOfPresentedViewInContainerView: CGRect {
    let origin = currentPosition.origin(for: maxFrame.height)
    let size = CGSize(width: maxFrame.width, height: maxFrame.height + 40)
    return CGRect(origin: origin, size: size)
  }
  
  override func containerViewWillLayoutSubviews() {
    presentedView?.frame = frameOfPresentedViewInContainerView
  }
  
  override func presentationTransitionDidEnd(_ completed: Bool) {
    animator = UIViewPropertyAnimator(duration: 1.0, timingParameters: springTiming)
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    presentedView?.addGestureRecognizer(panGesture)
  }
  
  @objc func handlePan(_ recogniser: UIPanGestureRecognizer) {
    let currentTranslation = recogniser.translation(in: presentedView).y
    let origin = currentPosition.origin(for: maxFrame.height)
    let offset = origin.y + currentTranslation
    
    if offset >= 0 {
      switch recogniser.state {
      case .changed, .began:
        presentedView?.frame.origin.y = offset
      case .ended:
        animate(to: .open)
      case .cancelled:
        animate(to: .partial)
      default:
        break
      }
      
    }
  }
  
//  private func animate(_ dragOffset: CGFloat) {
//    let distanceFromBottom = maxFrame.height - dragOffset
//
//    switch dragDirection {
//    case .up:
//      if (distanceFromBottom > maxFrame.height * DraggablePosition.open.upBoundary) {
//        animate(to: .open)
//      } else if (distanceFromBottom > maxFrame.height * DraggablePosition.half.upBoundary) {
//        animate(to: .half)
//      } else {
//        animate(to: .collapsed)
//      }
//    case .down:
//      if (distanceFromBottom > maxFrame.height * DraggablePosition.open.downBoundary) {
//        animate(to: .open)
//      } else if (distanceFromBottom > maxFrame.height * DraggablePosition.half.downBoundary) {
//        animate(to: .half)
//      } else {
//        animate(to: .collapsed)
//      }
//    }
//  }
  
  private func animate(to position: Position) {
    guard let animator = animator else { return }
    
    animator.addAnimations {
      self.presentedView?.frame.origin = position.origin(for: self.maxFrame.height)
    }
    
    animator.addCompletion { (animatingPosition) in
      if animatingPosition == .end {
        self.currentPosition = position
      }
    }
    
    animator.startAnimation()
  }
  
}


final class MapViewController: UIViewController {
  private var swipeUpTransitioningDelegate: SwipeUpTransitioningDelegate?
  
  override func loadView() {
    view = MKMapView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    let bottomVC = SwipeUpViewController()
    
    swipeUpTransitioningDelegate = SwipeUpTransitioningDelegate(viewControllerToPresent: bottomVC, presentingViewController: self)
    bottomVC.transitioningDelegate = swipeUpTransitioningDelegate
    bottomVC.modalPresentationStyle = .custom
    
    present(bottomVC, animated: true)
  }
}

final class SwipeUpViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    view.round(corners: [.topLeft, .topRight], radius: 25)
  }
}

let vc = MapViewController()
PlaygroundPage.current.liveView = vc
