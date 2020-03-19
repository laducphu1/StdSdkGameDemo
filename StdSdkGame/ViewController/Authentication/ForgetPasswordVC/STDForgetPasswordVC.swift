//
//  STDForgetPasswordVC.swift
//  SDKGame
//
//  Created by Fu on 3/5/20.
//  Copyright © 2020 PiPyL. All rights reserved.
//

import UIKit

class STDForgetPasswordVC: UIViewController {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var viewButton: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    //MARK: - Helper
    
    private func setupData() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        tap.cancelsTouchesInView = true;
//        self.view.addGestureRecognizer(tap)
        hideKeyboardWhenTappedAround()
    }
    
    @objc private func dismissKeyboard(sender: UITapGestureRecognizer) {
        nameTF.resignFirstResponder()
    }
    
    private func isValid() -> String? {
        
        if (nameTF.text?.count == 0) {
            return "Vui lòng nhập email"
        }
        
        return nil
    }
    
    private func forgetPassword() {
        
        guard let urlConfig = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLSynQuickDevice, urlConfig.count > 0 else {
            return
        }
        let currentTime = STDAppDataSingleton.sharedInstance.getTimeCurrent()
        let plainText = "\(nameTF.text!)\(currentTime)"
        let sign = STDAppDataSingleton.sharedInstance.hmac(plainText: plainText, key: kSDKSecretKey)
        let params = ["UserName": nameTF.text!,
                      "Sign":sign,
                      "Time":currentTime];
        
        STDNetworkController.shared.lostPassword(params: params) { [weak self] (success, error) in
            if let error = error {
                STDAlertController.showAlertController(title: "Thông báo", message: error, nil)
            } else {
                if success == true {
                    self?.viewButton.isHidden = false
                    STDAlertController.showAlertController(title: "Thông báo", message: "Thành công", nil)
                } else {
                    STDAlertController.showAlertController(title: "Thông báo", message: "Thất bại", nil)
                }
            }
        }
    }
    
    //MARK: - Actions
    
    @IBAction func didClickCountinue(_ sender: Any) {
        
        if let error = isValid() {
            STDAlertController.showAlertController(title: "Thông báo", message: error, nil)
            return
        }
        
        forgetPassword()
        
    }
    
    @IBAction func didClickResend(_ sender: Any) {
        if let error = isValid() {
            STDAlertController.showAlertController(title: "Thông báo", message: error, nil)
            return
        }
        
        forgetPassword()
    }
    
    @IBAction func didClickBackLogin(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didClickClose(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}


extension STDForgetPasswordVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
