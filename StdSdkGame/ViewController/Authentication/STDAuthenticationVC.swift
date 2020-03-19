//
//  STDAuthenticationVC.swift
//  SDKGame
//
//  Created by Fu on 3/5/20.
//  Copyright © 2020 PiPyL. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import AuthenticationServices
import GoogleSignIn

class STDAuthenticationVC: UIViewController {
    
    @IBOutlet weak var captchaLabel: UILabel!
    @IBOutlet weak var captchaTF: UITextField!
    @IBOutlet weak var captchaView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginSelectedView: UIButton!
    @IBOutlet weak var registerSelectedView: UIButton!
    
    @IBOutlet weak var failEmailLabel: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var failPhoneLabel: UILabel!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var failNameLabel: UILabel!
    @IBOutlet weak var failPasswordLabel: UILabel!
    @IBOutlet weak var signInAppleButton: UIButton!
    @IBOutlet weak var statusPassLogin: UIButton!
    
    @IBOutlet weak var nameRegisterTF: UITextField!
    @IBOutlet weak var passwordRegisterTF: UITextField!
    @IBOutlet weak var rePasswordRegisterTF: UITextField!
    @IBOutlet weak var emailRegisterTF: UITextField!
    @IBOutlet weak var failNameRegisterLabel: UILabel!
    @IBOutlet weak var failPasswordRegisterLabel: UILabel!
    @IBOutlet weak var failRePassRegisterLabel: UILabel!
    @IBOutlet weak var statusPassRegister: UIButton!
    @IBOutlet weak var statusRePassRegister: UIButton!
    
    var didFinishLogin: ((_ user: STDUserModel) -> Void)?
    var didFinishRegister: ((_ user: STDUserModel) -> Void)?
    var isRegiser = false
    var wrongPasswordCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        STDNetworkController.shared.getConfig { (_, _) in
            
        }
        nameTF.text = STDAppDataSingleton.sharedInstance.lastUserName
        GIDSignIn.sharedInstance()?.clientID = "794169653863-73i2n4g8a2nn4rdi9rfp911cv2vo09gu.apps.googleusercontent.com"
        setupData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        observeAppleSignInState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 13.0, *) {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) in
            
        }) { [weak self] (context) in
            if (UIDevice.current.orientation != UIDeviceOrientation.portrait && self?.isRegiser == true) {
                self?.scrollView.setContentOffset(CGPoint(x: self?.view.frame.width ?? 0, y: 0), animated: true)
            }
        }
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    //MARK: - Helper
    
    private func generateCaptcha() {
        captchaView.isHidden = false
        captchaLabel.text = String.generateCaptcha()
        captchaTF.text = ""
    }
    
    private func observeAppleSignInState() {
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(handleSignInWithAppleStateChanged), name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
        }
    }
    
    @objc private func handleSignInWithAppleStateChanged(notification: Notification) {
        
    }
    
    private func setupData() {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        if #available(iOS 13.0, *) {
            signInAppleButton.isHidden = false
        } else {
            signInAppleButton.isHidden = true
        }
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        tap.cancelsTouchesInView = true;
//        self.view.addGestureRecognizer(tap)
        
        hideKeyboardWhenTappedAround()
        nameTF.delegate = self
        passwordTF.delegate = self
        nameRegisterTF.delegate = self
        passwordRegisterTF.delegate = self
        rePasswordRegisterTF.delegate = self
    }
    
    @objc private func dismissKeyboard(sender: UITapGestureRecognizer) {
        nameTF.resignFirstResponder()
        passwordTF.resignFirstResponder()
        nameRegisterTF.resignFirstResponder()
        passwordRegisterTF.resignFirstResponder()
        rePasswordRegisterTF.resignFirstResponder()
    }
    
    private func loginFacebook(success:(@escaping(_ accessToken: String?, _ fbID: String?, _ error: String?) -> Void)) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { [weak self] (result, error) in
            if let error = error {
                success(nil, nil, error.localizedDescription)
                return
            }
            if result?.isCancelled == true {
                success(nil, nil, "Đã huỷ")
                return
            }
            success(result?.token?.tokenString, result?.token?.userID, nil)
        }
    }
    
    static func checkUserDidLogin(success:(@escaping(_ userModel: STDUserModel?, _ error: String?) -> Void)) {
        guard let user = STDAppDataSingleton.sharedInstance.userProfileModel else {
            success(nil, nil)
            return
        }
        
        guard let urlConfig = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLSynQuickDevice, urlConfig.count > 0 else {
            return
        }
        
        let currentTime = STDAppDataSingleton.sharedInstance.getTimeCurrent()
        let plainText = "\(user.accessToken)\(currentTime)"
        let sign = STDAppDataSingleton.sharedInstance.hmac(plainText: plainText, key: kSDKSecretKey)
        let params = ["AccessToken": user.accessToken,
                      "AppKey": kSDKAppKey,
                      "Sign": sign,
                      "Time": currentTime];
        
        STDNetworkController.shared.getUserByAccessToken(params: params) { (user, error) in
            if let user = user {
                STDAppDataSingleton.sharedInstance.userProfileModel = user
                success(user, nil)
            } else {
                success(nil, error)
            }
        }
        
    }
    
    
    private func isValidateLogin() -> Bool {
        failNameLabel.text = ""
        failPasswordLabel.text = ""
        
        if nameTF.text?.count == 0 {
            failNameLabel.text = "Vui lòng nhập tên đăng nhập"
            return false
        }
        
        if nameTF.text?.userNameIsValid() == false {
            failNameLabel.text = "Tên đăng nhập không đúng định dạng"
            return false
        }
        
        if passwordTF.text?.count == 0 {
            failPasswordLabel.text = "Vui lòng nhập mật khẩu"
            return false
        }
        
        if captchaView.isHidden == false {
            if captchaLabel.text != captchaTF.text {
                STDAlertController.showAlertController(title: "Thông báo", message: "Vui lòng nhập mã captcha chính xác", nil)
                generateCaptcha()
                return false
            }
        }
        
        return true
    }
    
    private func isValidateRegister() -> Bool {
        failRePassRegisterLabel.text = ""
        failPasswordRegisterLabel.text = ""
        failNameRegisterLabel.text = ""
        failEmailLabel.text = ""
        failPhoneLabel.text = ""
        guard let nameRegister = nameRegisterTF.text else {
            failNameRegisterLabel.text = "Vui lòng nhập tên đăng nhập"
            return false
        }
        
        if nameRegister.isOnlyLetterAndNumber() == false || nameRegister.count < 6 || nameRegister.count > 32 {
            failNameRegisterLabel.text = "Tên đăng nhập dài 6-32 ký tự Thường và Số";
            return false
        }
        
        if nameRegister.userNameIsValid() == false {
            failNameRegisterLabel.text = "Tài khoản không đúng định dạng"
            return false
        }
        
        if let phoneNumber = phoneTF.text, phoneNumber.count > 0 {
            if phoneNumber.isValidPhoneNumber() == false {
                failPhoneLabel.text = "Số điện thoại không đúng định dạng"
                return false
            }
        }
        
        if let email = emailTF.text, email.count > 0 {
            if email.isValidEmail() == false {
                failEmailLabel.text = "Email không đúng định dạng"
                return false
            }
        }
        
        guard let passwordRegister = passwordRegisterTF.text else {
            failPasswordRegisterLabel.text = "Vui lòng nhập mật khẩu"
            return false
        }
        
        if passwordRegister.count < 6 || passwordRegister.count > 32 || passwordRegister.isValidPassword() == false {
            failPasswordRegisterLabel.text = "Chiều dài 6 đến 32 ký tự. 1 chữ cái (A-Za-z) 1 số (0-9)"
            return false
        }
        
        if rePasswordRegisterTF.text?.count == 0 {
            failRePassRegisterLabel.text = "Vui lòng nhập mật khẩu xác nhận"
            return false
        }
        
        if passwordRegister != rePasswordRegisterTF.text {
            failRePassRegisterLabel.text = "Mật khẩu xác nhận không đúng"
            return false
        }
        
        return true
    }
    
    private func showSyncAccount() {
        let resourcesBundle = Bundle(for: STDSyncAccountVC.self)
        let vc = STDSyncAccountVC.init(nibName: "STDSyncAccountVC", bundle: resourcesBundle)
        vc.didSyncAccount = { [weak self] user in
            STDAppDataSingleton.sharedInstance.isSecondTimePlayNow = false
            STDAppDataSingleton.sharedInstance.userProfileModel = user
            self?.didFinishLogin?(user)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func loginQuickDevice() {
        
        guard let urlConfig = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLSynQuickDevice, urlConfig.count > 0 else {
            return
        }
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let currentTime = STDAppDataSingleton.sharedInstance.getTimeCurrent()
        let plainText = "\(deviceID)ios\(currentTime)"
        let sign = STDAppDataSingleton.sharedInstance.hmac(plainText: plainText, key: kSDKSecretKey)
        let params = ["DeviceID": deviceID,
                      "ClientOS": "ios",
                      "Sign": sign,
                      "Time": currentTime];
        
        STDNetworkController.shared.loginQuickDevice(params: params) { [weak self] (userModel, error) in
            if let userModel = userModel {
                if STDAppDataSingleton.sharedInstance.isSecondTimePlayNow && userModel.isSyn == false {
                    self?.showSyncAccount()
                    STDAppDataSingleton.sharedInstance.userProfileModel = userModel
                } else {
                    STDAppDataSingleton.sharedInstance.isSecondTimePlayNow = true
                    self?.didFinishLogin?(userModel)
                    STDAppDataSingleton.sharedInstance.userProfileModel = userModel
                }
                
            } else {
                STDAlertController.showAlertController(title: "Thông báo", message: error, nil)
            }
        }
    }
    
    private func registerAccount() {
        guard let urlConfig = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLSynQuickDevice, urlConfig.count > 0 else {
            return
        }
        let currentTime = STDAppDataSingleton.sharedInstance.getTimeCurrent()
        let plainText = "\(nameRegisterTF.text!)\(passwordRegisterTF.text!.MD5String())\(currentTime)"
        let sign = STDAppDataSingleton.sharedInstance.hmac(plainText: plainText, key: kSDKSecretKey)
        var params = ["UserName": nameRegisterTF.text!,
                      "Password": passwordRegisterTF.text!.MD5String(),
                      "Email": emailRegisterTF.text ?? "",
                      "Sign": sign,
                      "Time": currentTime];
        
        if let email = emailTF.text {
            params["Email"] = email
        }
        
        if let phoneNumber = phoneTF.text {
            params["PrimaryMobile"] = phoneNumber
        }
        
        STDNetworkController.shared.registerAccount(params: params) { [weak self] (userModel, error) in
            if let userModel = userModel {
                STDAppDataSingleton.sharedInstance.userProfileModel = userModel
                self?.didFinishLogin?(userModel)
                STDAppDataSingleton.sharedInstance.lastUserName = userModel.userName
            } else {
                STDAlertController.showAlertController(title: "Thông báo", message: error, nil)
            }
        }
    }
    
    private func loginAccount() {
        guard let urlConfig = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLSynQuickDevice, urlConfig.count > 0 else {
            return
        }
        let currentTime = STDAppDataSingleton.sharedInstance.getTimeCurrent()
        let plainText = "\(nameTF.text!)\(passwordTF.text!.MD5String())\(currentTime)"
        let sign = STDAppDataSingleton.sharedInstance.hmac(plainText: plainText, key: kSDKSecretKey)
        let params = ["UserName": nameTF.text!,
                      "Password": passwordTF.text!.MD5String(),
                      "Sign": sign,
                      "Time": currentTime];
        
        
        STDNetworkController.shared.login(params: params) { [weak self] (userModel, error) in
            if let userModel = userModel {
                self?.nameTF.text = ""
                self?.passwordTF.text = ""
                STDAppDataSingleton.sharedInstance.userProfileModel = userModel
                self?.didFinishLogin?(userModel)
                self?.wrongPasswordCount = 0
                self?.captchaView.isHidden = true
                STDAppDataSingleton.sharedInstance.lastUserName = userModel.userName
            } else {
                STDAlertController.showAlertController(title: "Thông báo", message: error, nil)
                self?.wrongPasswordCount += 1
                if self?.wrongPasswordCount == 4 {
                    self?.generateCaptcha()
                }
            }
        }
    }
    
    private func loginGoogleWithID(ggID: String, ggAccessToken: String) {
        guard let urlConfig = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLSynQuickDevice, urlConfig.count > 0 else {
            return
        }
        let currentTime = STDAppDataSingleton.sharedInstance.getTimeCurrent()
        let plainText = "\(ggAccessToken)\(ggID)\(currentTime)"
        let sign = STDAppDataSingleton.sharedInstance.hmac(plainText: plainText, key: kSDKSecretKey)
        let params = ["GoogleID": ggID,
                      "GoogleTokenID": ggAccessToken,
                      "ClientOS": "ios",
                      "Sign": sign,
                      "Time": currentTime];
        STDNetworkController.shared.loginGoogle(params: params) { [weak self] (userModel, error) in
            if let userModel = userModel {
                STDAppDataSingleton.sharedInstance.userProfileModel = userModel
                self?.didFinishLogin?(userModel)
            } else {
                STDAlertController.showAlertController(title: "Thông báo", message: error, nil)
            }
        }
    }
    
    @available(iOS 13.0, *)
    private func signInAppleWithAuthorization(authorization: ASAuthorization) {
        guard let urlConfig = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLSynQuickDevice, urlConfig.count > 0 else {
            return
        }
        let currentTime = STDAppDataSingleton.sharedInstance.getTimeCurrent()
        let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
        let authCode = String(data: appleIDCredential?.authorizationCode ?? Data(), encoding: .utf8) ?? ""
        let plainText = "\(authCode)\(appleIDCredential?.user ?? "")\(currentTime)"
        let sign = STDAppDataSingleton.sharedInstance.hmac(plainText: plainText, key: kSDKSecretKey)
        let params = ["AuthCode": authCode,
                      "AppleUserIdentifier": appleIDCredential?.user ?? "",
                      "AppleEmail": appleIDCredential?.email ?? "",
                      "AppleGivenName": appleIDCredential?.fullName?.givenName ?? "",
                      "AppleFamilyName": appleIDCredential?.fullName?.familyName ?? "",
                      "DeviceID": UIDevice.current.identifierForVendor?.uuidString ?? "",
                      "Sign": sign,
                      "Time": currentTime];
        STDNetworkController.shared.loginApple(params: params) { [weak self] (userModel, error) in
            if let userModel = userModel {
                STDAppDataSingleton.sharedInstance.userProfileModel = userModel
                self?.didFinishLogin?(userModel)
            } else {
                STDAlertController.showAlertController(title: "Thông báo", message: error, nil)
            }
        }
    }
    
    private func loginFacebookWithFBID(fbID: String, fbAccessToken: String) {
        guard let urlConfig = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLSynQuickDevice, urlConfig.count > 0 else {
            return
        }
        let currentTime = STDAppDataSingleton.sharedInstance.getTimeCurrent()
        let plainText = "\(fbAccessToken)\(fbID)\(currentTime)"
        let sign = STDAppDataSingleton.sharedInstance.hmac(plainText: plainText, key: kSDKSecretKey)
        let params = ["FacebookID": fbID,
                      "FacebookAccessToken": fbAccessToken,
                      "ClientOS": "ios",
                      "Sign": sign,
                      "Time": currentTime];
        STDNetworkController.shared.loginFacebook(params: params) { [weak self] (userModel, error) in
            if let userModel = userModel {
                STDAppDataSingleton.sharedInstance.userProfileModel = userModel
                self?.didFinishLogin?(userModel)
            } else {
                STDAlertController.showAlertController(title: "Thông báo", message: error, nil)
            }
        }
    }
    
    
    private func showRegisterSuccessAlert() {
        STDAlertController.showAlertController(title: "Thông báo", message: "Đăng ký thành công") { [weak self] (_, _) in
            self?.view.endEditing(true)
            self?.scrollView.setContentOffset(.zero, animated: true)
            self?.loginSelectedView.isHidden = false
            self?.registerSelectedView.isHidden = true
            self?.isRegiser = false
            self?.nameRegisterTF.text = ""
            self?.passwordRegisterTF.text = ""
            self?.rePasswordRegisterTF.text = ""
            self?.emailTF.text = ""
            self?.phoneTF.text = ""
        }
    }
    
    //MARK: - Actions
    
    @IBAction func reloadCaptchaAction(_ sender: Any) {
        generateCaptcha()
    }
    
    
    @IBAction func didClickShowHidePasswordLogin(_ sender: Any) {
        statusPassLogin.isSelected = !statusPassLogin.isSelected
        if statusPassLogin.isSelected {
            passwordTF.isSecureTextEntry = false
        } else {
            passwordTF.isSecureTextEntry = true
        }
    }
    
    @IBAction func didClickShowHidePassRegister(_ sender: Any) {
        statusPassRegister.isSelected = !statusPassRegister.isSelected
        if statusPassRegister.isSelected {
            passwordRegisterTF.isSecureTextEntry = false
        } else {
            passwordRegisterTF.isSecureTextEntry = true
        }
    }
    
    @IBAction func didClickShowHideRePassRegister(_ sender: Any) {
        statusRePassRegister.isSelected = !statusRePassRegister.isSelected
        if statusRePassRegister.isSelected {
            rePasswordRegisterTF.isSecureTextEntry = false
        } else {
            rePasswordRegisterTF.isSecureTextEntry = true
        }
        
    }
    
    
    @IBAction func didClickClose(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didClickLogin(_ sender: Any) {
        view.endEditing(true)
        scrollView.setContentOffset(.zero, animated: true)
        loginSelectedView.isHidden = false
        registerSelectedView.isHidden = true
        isRegiser = false
    }
    @IBAction func didClickRegister(_ sender: Any) {
        
        view.endEditing(true)
        scrollView.setContentOffset(CGPoint(x: view.frame.size.width, y: 0), animated: true)
        loginSelectedView.isHidden = true
        registerSelectedView.isHidden = false
        isRegiser = true
        
    }
    
    @IBAction func didClickForgetPassword(_ sender: Any) {
        view.endEditing(true)
        let resourcesBundle = Bundle(for: STDForgetPasswordVC.self)
        let vc = STDForgetPasswordVC.init(nibName: "STDForgetPasswordVC", bundle: resourcesBundle)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didClickLoginFacebook(_ sender: Any) {
        view.endEditing(true)
        loginFacebook { [weak self] (accessToken, fbID, error) in
            if let error = error {
                STDAlertController.showAlertController(title: "Thông báo", message: error, nil)
            }
            guard let accessToken = accessToken, let fbID = fbID else {
                STDAlertController.showAlertController(title: "Đã xảy ra lỗi", message: error, nil)
                return
            }
            self?.loginFacebookWithFBID(fbID: fbID, fbAccessToken: accessToken)
        }
        
    }
    
    @IBAction func didClickLoginGoogle(_ sender: Any) {
        view.endEditing(true)
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance()?.signOut()
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func didClickSignInApple(_ sender: Any) {
        view.endEditing(true)
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
        
    }
    
    @IBAction func didClickPlayNow(_ sender: Any) {
        view.endEditing(true)
        loginQuickDevice()
    }
    
    @IBAction func didClickLoginAction(_ sender: Any) {
        view.endEditing(true)
        
        if wrongPasswordCount == 5 {
            self.captchaView.isHidden = false
        }
        if isValidateLogin() {
            loginAccount()
        }
    }
    
    @IBAction func didClickRegisterAction(_ sender: Any) {
        
        view.endEditing(true)
        
        if isValidateRegister() {
            registerAccount()
        }
    }
    
}

extension STDAuthenticationVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension STDAuthenticationVC: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        GIDSignIn.sharedInstance().delegate = nil
        if error != nil {
            STDAlertController.showAlertController(title: "Thông báo", message: "Đã xảy ra lỗi khi đăng nhập với Google", nil)
        } else {
            loginGoogleWithID(ggID: user.userID, ggAccessToken: user.authentication.idToken)
        }
    }
    
}

extension STDAuthenticationVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        signInAppleWithAuthorization(authorization: authorization)
    }
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let errorMess = error.localizedDescription
        STDAlertController.showAlertController(title: "Thông báo", message: errorMess, nil)
        
    }
}
