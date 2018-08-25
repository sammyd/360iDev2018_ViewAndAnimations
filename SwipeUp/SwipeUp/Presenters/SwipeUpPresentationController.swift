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
    
    var visibleProportion: CGFloat {
      switch self {
      case .open: return 0.9
      case .closed: return 0.1
      }
    }
    
    func origin(for maxHeight: CGFloat) -> CGPoint {
      return CGPoint(x: 0, y: maxHeight * (1 - visibleProportion))
    }
  }
  
  private var position: Position = .closed

  private var maxFrame: CGRect {
    return UIWindow.maxFrame
  }
  
  override var frameOfPresentedViewInContainerView: CGRect {
    let origin = position.origin(for: maxFrame.height)
    let size = CGSize(width: maxFrame.width, height: maxFrame.height + 40)
    return CGRect(origin: origin, size: size)
  }
  
  override func containerViewWillLayoutSubviews() {
    presentedView?.frame = frameOfPresentedViewInContainerView
  }
  
  override func presentationTransitionDidEnd(_ completed: Bool) {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(recogniser:)))
    presentedView?.addGestureRecognizer(tapGesture)
  }
  
  @objc func handleTap(recogniser: UITapGestureRecognizer) {
    let nextPosition = position == .open ? Position.closed : .open
    self.presentedView?.frame.origin.y = nextPosition.origin(for: self.maxFrame.height).y
    self.position = nextPosition
  }
}
