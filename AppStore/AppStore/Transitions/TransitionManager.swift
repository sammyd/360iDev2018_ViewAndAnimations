/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import UIKit

enum TransitionType {
  case presentation
  case dismissal
  
  var blurAlpha: CGFloat { return self == .presentation ? 1 : 0 }
  var dimAlpha : CGFloat { return self == .presentation ? 0.1 : 0 }
  var cardMode : CardViewMode { return self == .presentation ? .card : .full }
  var cornerRadius : CGFloat { return self == .presentation ? 20 : 0 }
  var next: TransitionType { return self == .presentation ? .dismissal : .presentation }
}


class TransitionManager: NSObject, UIViewControllerAnimatedTransitioning {
  
  //MARK: Helpers
  let transitionDuration: Double = 0.8
  let shrinkDuration: Double = 0.2
  var transition: TransitionType = .presentation
  
  private let blurEffectView: UIVisualEffectView = {
    let blurEffect = UIBlurEffect(style: .light)
    return UIVisualEffectView(effect: blurEffect)
  }()
  
  private let dimmingView: UIView = {
    let view = UIView()
    view.backgroundColor = .black
    return view
  }()
  
  private let whiteScrollView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    return view
  }()
  
  private func addBackgroundViews(containerView: UIView) {
    blurEffectView.frame = containerView.frame
    blurEffectView.alpha = transition.next.blurAlpha
    containerView.addSubview(blurEffectView)
    
    dimmingView.frame = containerView.frame
    dimmingView.alpha = transition.next.dimAlpha
    containerView.addSubview(dimmingView)
  }
  
  private func createCardViewCopy(cardView: CardView) -> CardView {
    let cardModel = cardView.cardModel
    cardModel.viewMode = transition.cardMode
    let newAppView: AppView? = AppView(cardView.appView?.viewModel)
    let cardViewCopy = CardView(cardModel: cardModel, appView: newAppView)
    return cardViewCopy
  }
  
  //MARK: UIViewControllerAnimatedTransitioning protocol methods
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return transitionDuration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView
    containerView.subviews.forEach { $0.removeFromSuperview() }
    addBackgroundViews(containerView: containerView)
    
    let fromVC = transitionContext.viewController(forKey: .from)
    let toVC = transitionContext.viewController(forKey: .to)
    
    let todayVC = (transition == .presentation ? fromVC : toVC) as! TodayViewController
    guard let cardView = todayVC.selectedCellCardView() else { return }
    
    cardView.isHidden = true
    let cardViewCopy = createCardViewCopy(cardView: cardView)
    containerView.addSubview(cardViewCopy)
    
    let absoluteCardViewFrame = cardView.convert(cardView.frame, to: .none)
    cardViewCopy.frame = absoluteCardViewFrame
    
    whiteScrollView.frame = transition == .presentation ? cardView.containerView.frame : containerView.frame
    whiteScrollView.layer.cornerRadius = transition.cornerRadius
    cardViewCopy.insertSubview(whiteScrollView, aboveSubview: cardViewCopy.shadowView)
   
    if transition == .presentation {
      let toVC = toVC as! DetailViewController
      containerView.addSubview(toVC.view)
      toVC.viewsAreHidden = true
      
      moveAndConvertCardView(cardView: cardViewCopy, containerView: containerView, yOriginToMoveTo: 0) {
        cardView.isHidden = false
        toVC.viewsAreHidden = false
        cardViewCopy.removeFromSuperview()
        transitionContext.completeTransition(true)
      }
    } else {
      let fromVC = fromVC as! DetailViewController
      cardViewCopy.frame = fromVC.cardView!.frame
      fromVC.viewsAreHidden = true
      
      moveAndConvertCardView(cardView: cardViewCopy, containerView: containerView, yOriginToMoveTo: absoluteCardViewFrame.origin.y) {
        cardView.isHidden = false
        transitionContext.completeTransition(true)
      }
    }
  }
  
  private func makeShrinkAnimator(for cardView: CardView) -> UIViewPropertyAnimator {
    return UIViewPropertyAnimator(duration: shrinkDuration, curve: .easeOut, animations: {
      cardView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
      self.dimmingView.alpha = 0.05
    })
  }
  
  private func makeExpandContractAnimator(for cardView: CardView, containerView: UIView, yOrigin: CGFloat) -> UIViewPropertyAnimator {
    let springTiming = UISpringTimingParameters(dampingRatio: 0.75, initialVelocity: CGVector(dx: 0, dy: 4))
    let animator = UIViewPropertyAnimator(duration: transitionDuration - shrinkDuration, timingParameters: springTiming)
    
    animator.addAnimations {
      cardView.transform = .identity
      cardView.containerView.layer.cornerRadius = self.transition.next.cornerRadius
      cardView.frame.origin.y = yOrigin
      
      self.blurEffectView.alpha = self.transition.blurAlpha
      self.dimmingView.alpha = self.transition.dimAlpha
      
      self.whiteScrollView.layer.cornerRadius = cardView.containerView.layer.cornerRadius
      
      containerView.layoutIfNeeded()
      
      self.whiteScrollView.frame = self.transition == .presentation ? containerView.frame : cardView.containerView.frame
    }
    
    return animator
  }
  
  //MARK: Animation methods
  private func moveAndConvertCardView(cardView: CardView, containerView: UIView, yOriginToMoveTo: CGFloat, completion: @escaping () ->()) {
    let shrinkAnimator = makeShrinkAnimator(for: cardView)
    let expandAnimator = makeExpandContractAnimator(for: cardView, containerView: containerView, yOrigin: yOriginToMoveTo)
    
    expandAnimator.addCompletion { (_) in
      completion()
    }
    
    if self.transition == .presentation {
      shrinkAnimator.addCompletion { (_) in
        cardView.layoutIfNeeded()
        cardView.updateLayout(for: self.transition.next.cardMode)
        
        expandAnimator.startAnimation()
      }
      
      shrinkAnimator.startAnimation()
    } else {
      cardView.layoutIfNeeded()
      cardView.updateLayout(for: self.transition.next.cardMode)
      expandAnimator.startAnimation()
    }
  }
}

//MARK: UIViewControllerTransitioningDelegate
extension TransitionManager: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition = .presentation
    return self
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition = .dismissal
    return self
  }
}
