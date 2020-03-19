//
//  STDMainViewController.swift
//  SDKGame
//
//  Created by Fu on 3/5/20.
//  Copyright © 2020 PiPyL. All rights reserved.
//

import UIKit

class STDMainViewController: UIViewController {

    @IBOutlet weak var heightViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    
    var didFinishLogin: ((_ user: STDUserModel) -> Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if view.frame.size.height < view.frame.size.width {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) { // horizontal
                widthViewConstraint.constant = 600
                heightViewConstraint.constant = 600 * 3/4
            } else {
                widthViewConstraint.constant = view.frame.size.height
                heightViewConstraint.constant = view.frame.size.height * 3/4
            }
        } else {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) { // vertical
                widthViewConstraint.constant = 600 * 3/4
                heightViewConstraint.constant = 600
            } else {
                widthViewConstraint.constant = view.frame.size.width * 0.9
                heightViewConstraint.constant = view.frame.size.height * 0.85
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let resourcesBundle = Bundle(for: STDAuthenticationVC.self)
        let vc = STDAuthenticationVC.init(nibName: "STDAuthenticationVC", bundle: resourcesBundle)
        vc.didFinishLogin = { [weak self] user in
            self?.didFinishLogin?(user)
            STDAlertController.showAlertController(title: "Thông báo", message: "Đăng nhập thành công") { (alert, action) in
                self?.dismiss(animated: true, completion: nil)
            }
        }
        self.addChild(vc)
        vc.view.frame = CGRect(x: 0, y: 0, width: mainView.frame.size.width, height: mainView.frame.size.height)
        let nav = UINavigationController.init(rootViewController: vc)
        nav.view.frame = CGRect(x: 0, y: 0, width: mainView.frame.size.width, height: mainView.frame.size.height)
        self.addChild(nav)
        mainView.addSubview(nav.view)
        nav.didMove(toParent: self)
    }

}
