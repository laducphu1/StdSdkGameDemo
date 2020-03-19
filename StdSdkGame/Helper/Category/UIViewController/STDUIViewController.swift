//
//  STDUIViewController.swift
//  SDKGame
//
//  Created by Fu on 3/5/20.
//  Copyright © 2020 PiPyL. All rights reserved.
//

import UIKit

extension UIViewController {
    static var topViewController: UIViewController {
        return TopViewController()
    }
    
    /* Get current top screen */
    
    static func TopViewController( of viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController ) -> UIViewController {
        if let viewController = viewController as? UIPageViewController {
            return TopViewController(of: viewController.viewControllers?.first)
        }
        
        if let viewController = viewController as? UINavigationController {
            return TopViewController(of: viewController.visibleViewController)
        }
        
        if let viewController = viewController as? UITabBarController {
            if let viewController = viewController.selectedViewController {
                return TopViewController(of: viewController)
            }
        }
        
        if let viewController = viewController?.presentedViewController {
            return TopViewController(of: viewController)
        }
        
        return viewController ?? UIViewController()
    }
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
