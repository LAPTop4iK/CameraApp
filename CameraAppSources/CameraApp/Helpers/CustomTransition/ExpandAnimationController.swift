//
//  ExpandAnimationController.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import UIKit

class ExpandAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    let duration = 0.4

    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? TransitioningDelegateSourceView,
              let sourceView = fromVC.sourceView,
              let toView = transitionContext.view(forKey: .to),
              let finalFrameController = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        let initialFrame = containerView.convert(sourceView.bounds, from: sourceView)
        let finalFrame = transitionContext.finalFrame(for: finalFrameController)

        let scaleFactor = initialFrame.width / finalFrame.width

        toView.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        toView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
        toView.clipsToBounds = true

        containerView.addSubview(toView)

        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            toView.transform = .identity
            toView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
}

class ExpandTransitionDelegate: NSObject, UINavigationControllerDelegate {
    func navigationController(_: UINavigationController, animationControllerFor _: UINavigationController.Operation, from _: UIViewController, to _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ExpandAnimationController()
    }
}
