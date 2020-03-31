//
//  STDNetworkController.swift
//  SDKGame
//
//  Created by Fu on 3/5/20.
//  Copyright © 2020 PiPyL. All rights reserved.
//

import UIKit
import Foundation

var kDomain = "https://stagmsdk.1tap.vn/"
var kSDKSecretKey = "demomogamesdk123"
var kSDKAppKey = "demomogamesdk"
var kSDKClientOS = "ios"
var kSecretKey = "c3556e0597414d989a1b391bfe30a676"
var kGoogleClientId = "794169653863-73i2n4g8a2nn4rdi9rfp911cv2vo09gu.apps.googleusercontent.com"

@objc public class STDNetworkController: NSObject {
    @objc public static let shared = STDNetworkController()
    
    private override init() {
        super.init()
    }
    
    @objc public func checkUserDidLogin(_ success:(@escaping(_ userModel: STDUserModel?, _ error: String?) -> Void)) {
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
    
    @objc public func configSDKWith(_ sdkSecretKey: String, _ sdkAppkey: String, _ googleClientId: String) {
        kSDKSecretKey = sdkSecretKey
        kSDKAppKey = sdkAppkey
        kGoogleClientId = googleClientId
    }
    
    //MARK: - Package
    
    func receiptValidation(_ success:(@escaping(_ jsonString: String?, _ orderIDIAP: String?, _ error: String?) -> Void)) {
        
        let receiptPath = Bundle.main.appStoreReceiptURL?.path
        if FileManager.default.fileExists(atPath: receiptPath!){
            var receiptData:NSData?
            do{
                receiptData = try NSData(contentsOf: Bundle.main.appStoreReceiptURL!, options: NSData.ReadingOptions.alwaysMapped)
            }
            catch{
                success(nil, nil, error.localizedDescription)
            }
            //let receiptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let base64encodedReceipt = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)
            
            print(base64encodedReceipt!)
            
            
            let requestDictionary = ["receipt-data":base64encodedReceipt!,"password":kSecretKey]
            
            guard JSONSerialization.isValidJSONObject(requestDictionary) else {
                success(nil, nil,  "requestDictionary is not valid JSON")
                return
            }
            do {
                let requestData = try JSONSerialization.data(withJSONObject: requestDictionary)
                let validationURLString = "https://sandbox.itunes.apple.com/verifyReceipt"  // this works but as noted above it's best to use your own trusted server
                guard let validationURL = URL(string: validationURLString) else { print("the validation url could not be created, unlikely error"); return }
                let session = URLSession(configuration: URLSessionConfiguration.default)
                var request = URLRequest(url: validationURL)
                request.httpMethod = "POST"
                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
                let task = session.uploadTask(with: request, from: requestData) { (data, response, error) in
                    if let data = data , error == nil {
                        do {
                            guard let appReceiptJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                                success(nil, nil, "Error")
                                return
                            }
                            print("success. here is the json representation of the app receipt: \(appReceiptJSON)")
                            do {
                                let data1 =  try JSONSerialization.data(withJSONObject: appReceiptJSON, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
                                let convertedString = String(data: data1, encoding: String.Encoding.utf8)
                                if let receipt = appReceiptJSON["receipt"] as? [String: Any],
                                    let inApps = receipt["in_app"] as? [[String: Any]],
                                    let inApp = inApps.first,
                                    let orderId = inApp["original_transaction_id"] as? String {
                                        success(convertedString, String(orderId), nil)
                                }
                                
                            } catch _ {
                                success(nil, nil, "Đã xảy ra lỗi")
                            }
                        } catch _ {
                            success(nil, nil, "Đã xảy ra lỗi")
                        }
                    } else {
                        success(nil, nil, "Đã xảy ra lỗi")
                    }
                }
                task.resume()
            } catch let error as NSError {
                success(nil, nil, "Đã xảy ra lỗi \(error.localizedDescription)")
            }
            
        }
    }
    
    func chargeToGame(params: [String: Any], _ success:(@escaping(_ model: STDResultPaymentModel?, _ error: String?) -> Void)) {
        let uRLIAPCreateTrans = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLIAPChargeToGame ?? ""
        
        let urlString = String(format: "%@%@", kDomain, uRLIAPCreateTrans)
        
        var paramsLostPassword = params
        paramsLostPassword["AppKey"] = kSDKAppKey
        paramsLostPassword["ClientOS"] = "ios"
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        self.postRequest(url: urlString, params: paramsLostPassword, headers: headers) { (result, error) in
            if let error = error {
                success(nil, error)
                return
            }
            
            if let result = result as? [String: Any] {
                let paymentModel = STDResultPaymentModel(fromDictionary: result)
                success(paymentModel, nil)
                return
            }
            
            success(nil, "Đã xảy ra lỗi");
        }
    }
    
    func createTransaction(params: [String: Any], _ success:(@escaping(_ transactionID: String?, _ error: String?) -> Void)) {
        let uRLIAPCreateTrans = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLIAPCreateTrans ?? ""
        
        let urlString = String(format: "%@%@", kDomain, uRLIAPCreateTrans)
        
        var paramsCreateTrans = params
        paramsCreateTrans["AppKey"] = kSDKAppKey
        paramsCreateTrans["ClientOS"] = "ios"
        paramsCreateTrans["ServerID"] = "s1"
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        self.postRequest(url: urlString, params: paramsCreateTrans, headers: headers) { (result, error) in
            if let error = error {
                success(nil, error)
                return
            }
            
            if let result = result as? [String: Any] {
                if let transactionID = result["TransactionID"] as? String {
                    success(transactionID, nil)
                    return
                }
            }
            success(nil, "Đã xảy ra lỗi");
        }
    }
    
    func getListDefinePackage(params: [String: Any], _ success:(@escaping(_ packages: [STDPackageModel]?, _ error: String?) -> Void)) {
        let uRLIAPDefinePackage = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLIAPListDefinePackage ?? ""
        
        let urlString = String(format: "%@%@", kDomain, uRLIAPDefinePackage)
        
        var paramsFinal = params
        paramsFinal["AppKey"] = kSDKAppKey
        paramsFinal["ClientOS"] = "ios"
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        self.postRequest(url: urlString, params: paramsFinal, headers: headers) { (result, error) in
            if let error = error {
                success(nil, error)
                return
            }
            
            if let result = result as? [[String: Any]] {
                var packageArray = [STDPackageModel]()
                for dictionary in result {
                    let packageItem = STDPackageModel(fromDictionary: dictionary)
                    packageArray.append(packageItem)
                }
                
                success(packageArray, nil)
                return
            }
            success(nil, "Đã xảy ra lỗi");
        }
    }
    
    //MARK: - Authentication
    
    
    //Login apple
    func loginApple(params: [String: Any], _ success:(@escaping(_ user: STDUserModel?, _ error: String?) -> Void)) {
        let uRLGGAccessToken = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLSignInApple ?? ""
        
        let urlString = String(format: "%@%@", kDomain, uRLGGAccessToken)
        
        var paramsLoginGG = params
        paramsLoginGG["AppKey"] = kSDKAppKey
        paramsLoginGG["ClientOS"] = kSDKClientOS
        //paramsLoginGG["Time"] = STDAppDataSingleton.sharedInstance.getTimeCurrent()
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        self.postRequest(url: urlString, params: paramsLoginGG, headers: headers) { (result, error) in
            if let error = error {
                success(nil, error)
                return
            }
            
            if let result = result as? [String: Any] {
                let userModel = STDUserModel(fromDictionary: result)
                STDAppDataSingleton.sharedInstance.userProfileModel = userModel;
                success(userModel, nil);
                return
            }
            
            success(nil, "Đã xảy ra lỗi");
        }
    }
    
    //Login google
    func loginGoogle(params: [String: Any], _ success:(@escaping(_ user: STDUserModel?, _ error: String?) -> Void)) {
        let uRLGGAccessToken = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLGGAccessToken ?? ""
        
        let urlString = String(format: "%@%@", kDomain, uRLGGAccessToken)
        
        var paramsLoginGG = params
        paramsLoginGG["AppKey"] = kSDKAppKey
        //paramsLoginGG["Time"] = STDAppDataSingleton.sharedInstance.getTimeCurrent()
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        self.postRequest(url: urlString, params: paramsLoginGG, headers: headers) { (result, error) in
            if let error = error {
                success(nil, error)
                return
            }
            
            if let result = result as? [String: Any] {
                let userModel = STDUserModel(fromDictionary: result)
                STDAppDataSingleton.sharedInstance.userProfileModel = userModel;
                success(userModel, nil);
                return
            }
            
            success(nil, "Đã xảy ra lỗi");
        }
    }
    
    //Login fb
    
    func loginFacebook(params: [String: Any], _ success:(@escaping(_ user: STDUserModel?, _ error: String?) -> Void)) {
        let uRLFBAccessToken = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLFBAccessToken ?? ""
        
        let urlString = String(format: "%@%@", kDomain, uRLFBAccessToken)
        
        var paramsLoginFB = params
        paramsLoginFB["AppKey"] = kSDKAppKey
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        self.postRequest(url: urlString, params: paramsLoginFB, headers: headers) { (result, error) in
            if let error = error {
                success(nil, error)
                return
            }
            
            if let result = result as? [String: Any] {
                let userModel = STDUserModel(fromDictionary: result)
                STDAppDataSingleton.sharedInstance.userProfileModel = userModel;
                success(userModel, nil);
                return
            }
            
            success(nil, "Đã xảy ra lỗi");
        }
    }
    
    
    //login fb with dynamic framework?
    // not tested - need install pod / import framework first
    
    //    func loginFacebook(_ success:(@escaping(_ accessToken: String?, _ fbID: String?, _ error: String?) -> Void)) {
    //
    //        let loginManager = LoginManager()
    //        loginManager.logIn(
    //            permissions: [.publicProfile, .userFriends],
    //            viewController: self
    //        ) { result in
    //            switch result {
    //            case .cancelled:
    //                print("Login Cancelled")
    //                success(nil, nil, nil);
    //
    //            case .failed(let error):
    //                print("Login Fail \(error)")
    //                completionHandler(nil, nil, error.localizedDescription);
    //
    //            case .success(let grantedPermissions, _, _):
    //                print("Login success \(error)")
    //                success(FBSDKAccessToken.currentAccessToken.tokenString, FBSDKAccessToken.currentAccessToken.userID, nil);
    //
    //            }
    //        }
    //    }
    
    
    func loginQuickDevice(params: [String: Any], _ success:(@escaping(_ user: STDUserModel?, _ error: String?) -> Void)) {
        let uRLLoginQuickDevice = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLLoginQuickDevice ?? ""
        
        let urlString = String(format: "%@%@", kDomain, uRLLoginQuickDevice)
        
        var paramsLoginQuickDevice = params
        paramsLoginQuickDevice["AppKey"] = kSDKAppKey
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        self.postRequest(url: urlString, params: paramsLoginQuickDevice, headers: headers) { (result, error) in
            if let error = error {
                success(nil, error)
                return
            }
            
            if let result = result as? [String: Any] {
                let userModel = STDUserModel(fromDictionary: result)
                STDAppDataSingleton.sharedInstance.userProfileModel = userModel;
                success(userModel, nil);
                return
            }
            
            success(nil, "Đã xảy ra lỗi");
        }
    }
    
    func lostPassword(params: [String: Any], _ success:(@escaping(_ isSuccess: Bool?, _ error: String?) -> Void)) {
        let uRLLostPassword = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLLostPassword ?? ""
        
        let urlString = String(format: "%@%@", kDomain, uRLLostPassword)
        
        var paramsLostPassword = params
        paramsLostPassword["AppKey"] = kSDKAppKey
        //paramsLostPassword["Time"] = STDAppDataSingleton.sharedInstance.getTimeCurrent()
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        self.postRequest(url: urlString, params: paramsLostPassword, headers: headers) { (result, error) in
            if let error = error {
                success(nil, error)
                return
            }
            
            if let result = result as? Bool {
                success(result, nil);
                return
            }
            
            success(nil, "Đã xảy ra lỗi");
        }
    }
    
    
    func logoutByAccessToken(params: [String: Any], _ success:(@escaping(_ isSuccess: Bool?, _ error: String?) -> Void)) {
        let uRLLogoutToken = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLLogoutToken ?? ""
        let urlString = String(format: "%@%@", kDomain, uRLLogoutToken)
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        self.postRequest(url: urlString, params: params, headers: headers) { (result, error) in
            if let error = error {
                success(nil, error)
                return
            }
            
            if let result = result as? Bool {
                success(result, nil);
                return
            }
            
            success(nil, "Đã xảy ra lỗi");
        }
    }
    
    func getUserByAccessToken(params: [String: Any], _ success:(@escaping(_ userModel: STDUserModel?, _ error: String?) -> Void)) {
        let uRLGetUserToken = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLGetUserToken ?? ""
        let urlString = String(format: "%@%@", kDomain, uRLGetUserToken)
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        self.postRequest(url: urlString, params: params, headers: headers) { (result, error) in
            if let error = error {
                success(nil, error)
                return
            }
            
            if let result = result as? [String: Any] {
                let userModel = STDUserModel(fromDictionary: result)
                success(userModel, nil);
                return
            }
            
            success(nil, "Đã xảy ra lỗi");
        }
    }
    
    func login(params: [String: Any], _ success:(@escaping(_ userModel: STDUserModel?, _ error: String?) -> Void)) {
        let uRLLogin = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLLogin ?? ""
        let urlString = String(format: "%@%@", kDomain, uRLLogin)
        
        var paramsLogin = params
        paramsLogin["AppKey"] = kSDKAppKey
        let ipAdress = STDAppDataSingleton.sharedInstance.getIPAddress() ?? ""
        paramsLogin["ClientIP"] = ipAdress
        paramsLogin["ClientOS"] = kSDKClientOS
        //paramsLogin["Time"] = STDAppDataSingleton.sharedInstance.getTimeCurrent()
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        self.postRequest(url: urlString, params: paramsLogin, headers: headers) { (result, error) in
            if let error = error {
                success(nil, error)
                return
            }
            
            if let result = result as? [String: Any] {
                let userModel = STDUserModel(fromDictionary: result)
                STDAppDataSingleton.sharedInstance.userProfileModel = userModel;
                success(userModel, nil);
                return
            }
            
            success(nil, "Đăng nhập thất bại");
        }
    }
    
    func registerAccount(params: [String: Any], _ success:(@escaping(_ userModel: STDUserModel?, _ error: String?) -> Void)) {
        let uRLRegister = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLRegister ?? ""
        let urlString = String(format: "%@%@", kDomain, uRLRegister)
        
        var paramsRegister = params
        paramsRegister["AppKey"] = kSDKAppKey
        let ipAdress = STDAppDataSingleton.sharedInstance.getIPAddress() ?? ""
        paramsRegister["ClientIP"] = ipAdress
        paramsRegister["ClientOS"] = kSDKClientOS
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        self.postRequest(url: urlString, params: paramsRegister, headers: headers) { (result, error) in
            if let error = error {
                success(nil, error)
                return
            }
            
            if let result = result as? [String: Any] {
                let userModel = STDUserModel(fromDictionary: result)
                STDAppDataSingleton.sharedInstance.userProfileModel = userModel;
                success(userModel, nil);
                return
            }
            
            success(nil, "Đăng ký thất bại");
        }
    }
    
    func synQuickDevice(params: [String: String], _ success:(@escaping(_ userModel: STDUserModel?, _ error: String?) -> Void)) {
        let uRLSynQuickDevice = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLSynQuickDevice ?? ""
        let urlString = String(format: "%@%@", kDomain, uRLSynQuickDevice)
        
        var paramsSync = params
        paramsSync["AppKey"] = kSDKAppKey
        paramsSync["ClientOS"] = kSDKClientOS
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        self.postRequest(url: urlString, params: paramsSync, headers: headers) { (result, error) in
            if let error = error {
                success(nil, error)
                return
            }
            
            if let result = result as? [String: Any] {
                let userModel = STDUserModel(fromDictionary: result)
                STDAppDataSingleton.sharedInstance.userProfileModel = userModel;
                success(userModel, nil);
                return
            }
            
            success(nil, "Đồng bộ thất bại");
        }
    }
    
    //MARK: - Config
    
    @objc public func getConfig( _ success:(@escaping(_ urlModel: STDURLModel?, _ error: String?) -> Void)) {
        let urlString = String(format: "%@config.html", kDomain)
        let timeCurrent = STDAppDataSingleton.sharedInstance.getTimeCurrent()
        
        let plainText = String(format: "%@%@%@", kSDKAppKey, "1.0.1", timeCurrent)
        let sign = STDAppDataSingleton.sharedInstance.hmac(plainText: plainText, key: kSDKSecretKey)
        
        var paramsConfig = [String: String]()
        paramsConfig["AppKey"] = kSDKAppKey
        paramsConfig["Time"] = timeCurrent
        paramsConfig["ClientOS"] = kSDKClientOS
        paramsConfig["VersionSDK"] = "1.0.1"
        paramsConfig["Sign"] = sign
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        self.postRequest(url: urlString, params: paramsConfig, headers: headers) { (result, error) in
            if let error = error {
                success(nil, error)
                return
            }
            
            if let result = result as? [String: Any] {
                let uRLModel = STDURLModel(fromDictionary: result)
                STDAppDataSingleton.sharedInstance.urlsConfig = uRLModel
                
                success(uRLModel, nil);
                return
            }
            
            success(nil, "Đã xảy ra lỗi");
        }
    }
    
    func logOutUser( _ success:(@escaping(_ isSuccess: Bool, _ error: String?) -> Void)) {
        
        guard let accessToken = STDAppDataSingleton.sharedInstance.userProfileModel?.accessToken, let logOutUrl = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLLogoutToken else {
            success(false, "Đăng xuất thất bại")
            return
        }
        
        let urlString = String(format: "%@%@",kDomain, logOutUrl)
        let timeCurrent = STDAppDataSingleton.sharedInstance.getTimeCurrent()
        
        let plainText = String(format: "%@%@", accessToken, timeCurrent)
        let sign = STDAppDataSingleton.sharedInstance.hmac(plainText: plainText, key: kSDKSecretKey)
        
        var paramsConfig = [String: String]()
        paramsConfig["AppKey"] = kSDKAppKey
        paramsConfig["Time"] = timeCurrent
        paramsConfig["AccessToken"] = accessToken
        paramsConfig["Sign"] = sign
        
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        self.postRequest(url: urlString, params: paramsConfig, headers: headers) { (result, error) in
            if let error = error {
                success(false, error)
                return
            }
            
            if let result = result as? Int  {
                if result == 1 {
                    success(true, nil)
                } else {
                    success(false, nil)
                }
                return
            }
            
            success(false, "Đăng xuất thất bại");
        }
    }
}

extension STDNetworkController {
    //MARK: - Base request
    
    func getRequest(url: String, success:(@escaping(_ json: Any?, _ error: String?) -> Void)) {
        let sharedSession = URLSession.shared
        guard let url = URL(string: url) else {
            success(nil, "Đã xảy ra lỗi")
            return
        }
        Indicator.sharedInstance.showIndicator()
        let dataTask = sharedSession.dataTask(with: url) { (data, response, error) in
            if let error = error {
                success(nil, error.localizedDescription)
                Indicator.sharedInstance.hideIndicator()
                return
            }
            
            if let data = data {
                if let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                    success(result, nil)
                    Indicator.sharedInstance.hideIndicator()
                    return
                }
            }
            Indicator.sharedInstance.hideIndicator()
            success (nil, "Đã xảy ra lỗi")
        }
        
        dataTask.resume()
    }
    
    func getRequest(url: String, params: [String:Any], headers: [String: String], success:(@escaping(_ json: Any?, _ error: String?) -> Void)) {
        let sharedSession = URLSession.shared
        guard let url = URL(string: url) else {
            success(nil, "Đã xảy ra lỗi")
            return
        }
        
        var request = URLRequest(url: url)
        headers.keys.forEach { (key) in
            request.setValue(headers[key], forHTTPHeaderField: key)
        }
        request.httpMethod = "GET"
        
        if let paramsData = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
            if let paramsString = String(data: paramsData, encoding: .utf8) {
                let encodedData = paramsString.data(using: .utf8)
                request.httpBody = encodedData
            }
        }
        
        let dataTask = sharedSession.dataTask(with: request, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    success(nil, error.localizedDescription)
                    return
                }
                
                if let data = data {
                    if let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                        success(result, nil)
                        return
                    }
                }
                
                success (nil, "Đã xảy ra lỗi")
            }})
        
        dataTask.resume()
    }
    
    func postRequest(url: String, params: [String:Any], headers: [String: String], success:(@escaping(_ json: Any?, _ error: String?) -> Void)) {
        
        let postData = NSMutableData()
        for key in params.keys {
            if let data = "&\(key)=\(params[key] ?? "")".data(using: .utf8) {
                postData.append(data)
            }
        }
        
        let sharedSession = URLSession.shared
        guard let url = URL(string: url) else {
            success(nil, "Đã xảy ra lỗi")
            return
        }
        
       
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        headers.keys.forEach { (value) in
            request.setValue(headers[value], forHTTPHeaderField: value)
        }
        request.httpBody = postData as Data
        request.httpMethod = "POST"
        Indicator.sharedInstance.showIndicator()
        let dataTask = sharedSession.dataTask(with: request, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    success(nil, error.localizedDescription)
                    if (STDAppDataSingleton.sharedInstance.isEnableDebugs) {
                        let debugString = "API: \(url): \(error.localizedDescription)"
                        STDAppDataSingleton.sharedInstance.debugsString = "\(STDAppDataSingleton.sharedInstance.debugsString)\n\n\(debugString)"
                    }
                    Indicator.sharedInstance.hideIndicator()
                    return
                }
                
                if let data = data {
                    if let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                        
                        Indicator.sharedInstance.hideIndicator()
                        if let eInt = result["e"] as? Int, eInt == 0 {
                            success(result["r"], nil)
                            if (STDAppDataSingleton.sharedInstance.isEnableDebugs) {
                                let debugString = "API: \(url): \(result["r"] ?? "")"
                                STDAppDataSingleton.sharedInstance.debugsString = "\(STDAppDataSingleton.sharedInstance.debugsString)\n\n\(debugString)"
                            }
                        } else {
                            success(nil, result["r"] as? String)
                            if (STDAppDataSingleton.sharedInstance.isEnableDebugs) {
                                let debugString = "API: \(url): \(result["r"] ?? "")"
                                STDAppDataSingleton.sharedInstance.debugsString = "\(STDAppDataSingleton.sharedInstance.debugsString)\n\n\(debugString)"
                            }
                        }
                        return
                    }
                }
                Indicator.sharedInstance.hideIndicator()
                success (nil, "Đã xảy ra lỗi")
            }})
        
        dataTask.resume()
    }
}

extension String {
    func toNSError() -> NSError {
        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : self])
        return error
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}
extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

