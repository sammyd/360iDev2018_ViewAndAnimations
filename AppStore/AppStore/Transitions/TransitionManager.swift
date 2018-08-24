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
}

class TransitionManager: NSObject, UIViewControllerAnimatedTransitioning {
  
  //MARK: Helpers
  let transitionDuration: Double = 0.8
  let shrinkDuration: Double = 0.2
  var transition: TransitionType = .presentation
  
  private let blurEffectView: UIVisualEffectView = {
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
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
    blurEffectView.alpha = 0
    containerView.addSubview(blurEffectView)
    
    dimmingView.frame = containerView.frame
    dimmingView.alpha = 0
    containerView.addSubview(dimmingView)
  }
  
  private func createCardViewCopy(cardView: CardView) -> CardView {
    let cardModel = cardView.cardModel
    cardModel.viewMode = .card
    let newAppView: AppView? = AppView(cardView.appView?.viewModel)
    let cardViewCopy = CardView(cardModel: cardModel, appView: newAppView)
    return cardViewCopy
  }
  
  //MARK: UIViewControllerAnimatedTransitioning protocol methods
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return transitionDuration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    if let toVC = transitionContext.viewController(forKey: .to) as? DetailViewController {
      transitionContext.containerView.addSubview(toVC.view)
      transitionContext.completeTransition(true)
    } else {
      transitionContext.completeTransition(true)
    }
  }
  
  //MARK: Animation methods
  private func moveAndConvertCardView(cardView: CardView, containerView: UIView, yOriginToMoveTo: CGFloat, completion: @escaping () ->()) {

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
