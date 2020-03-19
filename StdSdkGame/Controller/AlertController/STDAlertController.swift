//
//  STDAlertController.swift
//  SDKGame
//
//  Created by Fu on 3/5/20.
//  Copyright © 2020 PiPyL. All rights reserved.
//

import UIKit
import Foundation

typealias ConfirmButtonTapBlock = (_ alert: UIAlertController?, _ action: UIAlertAction?) -> Void


class STDAlertController: NSObject {
    
    /* Show Custom alert */

    static public func showOptionAlertController(title: String, message: String, _ completionHandler: (( _ alert: UIAlertController, _ action: UIAlertAction, _ isConfirm: Bool) -> Void)?) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction.init(title: "Huỷ Bỏ", style: .cancel, handler: { (action) in
            completionHandler?(alert, action, false)
        }))
        alert.addAction(UIAlertAction.init(title: "Đồng Ý", style: .default, handler: { (action) in
            completionHandler?(alert, action, true)
        }))
        let currentVC = UIViewController.topViewController
        currentVC.present(alert, animated: true)
    }

    /* Show custom alert */

    static public func showAlertController(title: String, message: String?, _ completionHandler: (( _ alert: UIAlertController, _ action: UIAlertAction) -> Void)?) {
        let alert = UIAlertController.init(title: title, message: message ?? "Đã có lỗi xảy ra", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: { (action) in
            completionHandler?(alert, action)
        }))
        UIViewController.topViewController.present(alert, animated: true)
    }
}
