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


@objc public class STDAlertController: NSObject {
    
    /* Show Custom alert */

    @objc static public func showOptionAlertController(title: String, message: String, _ completionHandler: (( _ alert: UIAlertController, _ action: UIAlertAction, _ isConfirm: Bool) -> Void)?) {
        let alert = UIAlertController.init(title: title.localizable, message: message.localizable, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction.init(title: "Huỷ Bỏ".localizable, style: .cancel, handler: { (action) in
            completionHandler?(alert, action, false)
        }))
        alert.addAction(UIAlertAction.init(title: "Đồng Ý".localizable, style: .default, handler: { (action) in
            completionHandler?(alert, action, true)
        }))
        let currentVC = UIViewController.topViewController
        currentVC.present(alert, animated: true)
    }

    /* Show custom alert */

    @objc static public func showAlertController(title: String, message: String?, _ completionHandler: (( _ alert: UIAlertController, _ action: UIAlertAction) -> Void)?) {
        let mess = message ?? "Đã có lỗi xảy ra"
        let alert = UIAlertController.init(title: title.localizable, message: mess.localizable , preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction.init(title: "Ok".localizable, style: .default, handler: { (action) in
            completionHandler?(alert, action)
        }))
        UIViewController.topViewController.present(alert, animated: true)
    }
}
