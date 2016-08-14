//
//  CustomPickerPresentationAnimator.swift
//  Spare
//
//  Created by Matt Quiros on 15/08/2016.
//  Copyright © 2016 Matt Quiros. All rights reserved.
//

import UIKit

class CustomPickerPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return Duration.Animation
//        return 5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = transitionContext.containerView(),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey) as? __CPVCView
            else {
                return
        }
        
        // Initial values
        toView.layoutIfNeeded()
        toView.frame = transitionContext.finalFrameForViewController(toVC)
        toView.dimView.alpha = 0
        toView.tableViewBottom.constant = -(toView.tableViewHeight.constant)
        toView.setNeedsLayout()
        toView.layoutIfNeeded()
        containerView.addSubview(toView)
        
        UIView.animateWithDuration(
            self.transitionDuration(transitionContext),
            animations: {
                toView.dimView.alpha = 0.7
                toView.tableViewBottom.constant = 0
                toView.setNeedsLayout()
                toView.layoutIfNeeded()
            },
            completion: { _ in
                let successful = transitionContext.transitionWasCancelled() == false
                if successful == false {
                    toView.removeFromSuperview()
                }
                transitionContext.completeTransition(successful)
        })
    }
    
}