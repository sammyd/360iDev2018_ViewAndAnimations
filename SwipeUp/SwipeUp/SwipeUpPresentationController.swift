/*
 * Copyright (c) 2018 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

fileprivate extension CGFloat {
  // Spring animation
  static let springDampingRatio: CGFloat = 0.7
  static let springInitialVelocityY: CGFloat =  10
}

fileprivate extension Double {
  // Spring animation
  static let animationDuration: Double = 0.8
}

class SwipeUpPresentationController: UIPresentationController {
  private enum Position {
    case open
    case closed
    case partial
    
    var visibleProportion: CGFloat {
      switch self {
      case .open: return 0.9
      case .closed: return 0.1
      case .partial: return 0.45
      }
    }
    
    var dimmedAlpha: CGFloat {
      switch self {
      case .open: return 0.6
      default: return 0
      }
    }
    
    func origin(for maxHeight: CGFloat) -> CGPoint {
      return CGPoint(x: 0, y: maxHeight * (1 - visibleProportion))
    }
    
    static func closest(for offset: CGFloat, maxHeight: CGFloat) -> Position {
      return [Position.open, .closed, .partial].reduce((position: .open, delta: .greatestFiniteMagnitude), { (currentWinner, position) -> (position: Position, delta: CGFloat) in
        let originY = position.origin(for: maxHeight).y
        let delta = abs(originY - offset)
        if delta < currentWinner.delta {
          return (position: position, delta: delta)
        } else {
          return currentWinner
        }
      }).position
    }
    
    static func proportionBetweenPartialAndOpen(for offset: CGFloat, maxHeight: CGFloat) -> CGFloat {
      let offsetOpen = Position.open.origin(for: maxHeight).y
      let offsetPartial = Position.partial.origin(for: maxHeight).y
      
      let proportion = (offset - offsetPartial) / (offsetOpen - offsetPartial)
      return proportion.clamp(min: 0, max: 1)
    }
  }

  private var position: Position = .closed
  private var maxFrame: CGRect {
    return UIWindow.maxFrame
  }
  
  private lazy var animator: UIViewPropertyAnimator = {
    let timingParams = UISpringTimingParameters(dampingRatio: .springDampingRatio, initialVelocity: CGVector(dx: 0, dy: .springInitialVelocityY))
    let animator = UIViewPropertyAnimator(duration: .animationDuration, timingParameters: timingParams)
    animator.isInterruptible = true
    return animator
  }()
  
  private let dimmedView = UIView()
  
  override var frameOfPresentedViewInContainerView: CGRect {
    let origin = position.origin(for: maxFrame.height)
    let size = CGSize(width: maxFrame.width, height: maxFrame.height + 40)
    return CGRect(origin: origin, size: size)
  }
  
  override func containerViewWillLayoutSubviews() {
    presentedView?.frame = frameOfPresentedViewInContainerView
  }
  
  override func presentationTransitionWillBegin() {
    guard let containerView = containerView else { return }
    
    containerView.insertSubview(dimmedView, at: 0)
    dimmedView.frame = containerView.bounds
    dimmedView.backgroundColor = .black
    dimmedView.isUserInteractionEnabled = false
    dimmedView.alpha = 0
  }
  
  override func presentationTransitionDidEnd(_ completed: Bool) {
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recogniser:)))
    presentedView?.addGestureRecognizer(panGesture)
  }
  
  
  @objc func handlePan(recogniser: UIPanGestureRecognizer) {
    let translation = recogniser.translation(in: presentedView)
    let originForCurrentPosition = position.origin(for: maxFrame.height)
    let offset = originForCurrentPosition.y + translation.y
    
    if offset >= 0 {
      switch recogniser.state {
      case .changed, .began:
        presentedView?.frame.origin.y = offset
        dimmedView.alpha = Position.proportionBetweenPartialAndOpen(for: offset, maxHeight: maxFrame.height) * Position.open.dimmedAlpha
      case .ended, .cancelled:
        animate(to: offset)
      default:
        break
      }
    } else {
      if recogniser.state == .ended {
        animate(to: offset)
      }
    }
  }
  
}

// Animations
extension SwipeUpPresentationController {
  private func animate(to offset: CGFloat) {
    animate(to: Position.closest(for: offset, maxHeight: maxFrame.height))
  }
  
  private func animate(to newPosition: Position) {
    animator.addAnimations {
      self.presentedView?.frame.origin.y = newPosition.origin(for: self.maxFrame.height).y
      self.dimmedView.alpha = newPosition.dimmedAlpha
    }
    
    animator.addCompletion { (animatingPosition) in
      if animatingPosition == .end {
        self.position = newPosition
      }
    }
    
    animator.startAnimation()
  }
}
