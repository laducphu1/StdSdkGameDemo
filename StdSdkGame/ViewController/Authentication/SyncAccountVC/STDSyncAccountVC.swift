//
//  STDSyncAccountVC.swift
//  SDKGame
//
//  Created by Fu on 3/5/20.
//  Copyright © 2020 PiPyL. All rights reserved.
//

import UIKit

class STDSyncAccountVC: UIViewController {
    
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    var didSyncAccount: ((_ user: STDUserModel) -> Void)?
    
    //MARK: - Helper
    
    private func setupData() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        tap.cancelsTouchesInView = true;
//        self.view.addGestureRecognizer(tap)
        hideKeyboardWhenTappedAround()
    }
    
    @objc private func dismissKeyboard(sender: UITapGestureRecognizer) {
        userNameTF.resignFirstResponder()
        passwordTF.resignFirstResponder()
        confirmPasswordTF.resignFirstResponder()
    }
    
    private func isValid() -> String? {
        
        if userNameTF.text?.count == 0 {
            return "Vui lòng nhập tên đăng nhập"
        }
        
        if passwordTF.text?.count == 0 {
            return "Vui lòng nhập mật khẩu"
        }
        
        if confirmPasswordTF.text?.count == 0 {
            return "Vui lòng nhập mật khẩu xác nhận"
        }
        
        if confirmPasswordTF.text != passwordTF.text {
            return "Mật khẩu xác nhận không đúng"
        }
        return nil
    }
    
    @IBAction func didClickClose(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didClickSyncAccount(_ sender: Any) {
        if let error = isValid() {
            STDAlertController.showAlertController(title: "Thông báo", message: error, nil)
            return
        }
        
        guard let urlConfig = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLSynQuickDevice, urlConfig.count > 0 else {
            return
        }
        guard let password = passwordTF.text , !password.isEmpty, let userName = userNameTF.text, !userName.isEmpty else {
            STDAlertController.showAlertController(title: "Thông báo", message: "Vui lòng nhập tài khoản và mật khẩu", nil)
            return
        }
        let currentTime = STDAppDataSingleton.sharedInstance.getTimeCurrent()
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let plainText = "\(deviceID)\(userName)\(password.MD5String())\(currentTime)"
        let sign = STDAppDataSingleton.sharedInstance.hmac(plainText: plainText, key: kSDKSecretKey)
        let params = ["UserName": userNameTF.text!,
                      "Password":passwordTF.text!.MD5String(),
                      "Sign":sign,
                      "Time":currentTime,
                      "DeviceID":deviceID];
        
        STDNetworkController.shared.synQuickDevice(params: params) { [weak self] (userModel, error) in
            if let user = userModel {
                self?.didSyncAccount?(user)
            } else {
                STDAlertController.showAlertController(title: "Thông báo", message: error, nil)
            }
        }
        
    }

}

//MARK: - LifeCycle

extension STDSyncAccountVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
}


//MARK: - TextField delegate

extension STDSyncAccountVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
