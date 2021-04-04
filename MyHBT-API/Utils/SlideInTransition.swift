//
//  SlideInTransition.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/17/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class SlideInTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPresenting = false
    let dimingView = UIView()
    
    var menuProtocol: MenuProtocol?
    
    init(menuProtocol: MenuProtocol) {
        self.menuProtocol = menuProtocol
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        guard let fromViewController = transitionContext.viewController(forKey: .from) else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        let finalWidth = toViewController.view.bounds.width * 0.8
        let finalHeight = toViewController.view.bounds.height
        
        if (isPresenting) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickTransparentView))
            
            // Add diming view
            dimingView.backgroundColor = .black
            dimingView.alpha = 0
            containerView.addSubview(dimingView)
            dimingView.frame = containerView.bounds
            
            dimingView.addGestureRecognizer(tapGesture)
            
            // Add the menu view controller
            containerView.addSubview(toViewController.view)
            
            // Inital frame for the menu view controller
            toViewController.view.frame = CGRect(x: -finalWidth, y: 0, width: finalWidth, height: finalHeight)
        }
        
        // Animate onto screen
        let transform = {
            self.dimingView.alpha = 0.5
            toViewController.view.transform = CGAffineTransform(translationX: finalWidth, y: 0)
        }
        
        // Animate back off screen
        let identity = {
            self.dimingView.alpha = 0
            fromViewController.view.transform = .identity
        }
        
        // Animate it
        let duration = transitionDuration(using: transitionContext)
        let isCancelled = transitionContext.transitionWasCancelled
        UIView.animate(withDuration: duration, animations: {
            self.isPresenting ? transform() : identity()
        }) { (_) in
            transitionContext.completeTransition(!isCancelled)
        }
    }
    
    // The function to close the menu when anywhere outside of menu is tapped
    @objc func onClickTransparentView () {
        print("Outside tapped")
        self.menuProtocol!.closeMenu()
    }
}
