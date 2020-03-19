//
//  STDPaymentController.swift
//  SDKGame
//
//  Created by Fu on 3/5/20.
//  Copyright © 2020 PiPyL. All rights reserved.
//

import UIKit
import StoreKit

class STDPaymentController: NSObject {
    @objc static let sharedInstance = STDPaymentController()
    
    var productIdentifier = ""
    var productID = ""
    var productsRequest = ""
    var iapProducts = ""
    var packageSelected = STDPackageModel()
    var transactionID = ""
    
    override init() {
        super.init()
        registerNotification()
    }
    
    private func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(paymentTransactionUpdated), name: NSNotification.Name(rawValue: StoreKitManager.NOTIFICATION_PAYMENT_TRANSACTION_UPDATED), object: nil)
    }
    
    private func convertDictionaryToJsonString(_ dict: [String: Any]) -> String {
        let encryptedReceipt = appStoreReceiptData?.base64EncodedString(options: [])
        return encryptedReceipt ?? ""
//        var _ : NSError?

//        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)

//        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as String? ?? ""
//        return jsonString
    }
    
    private func verifyReceipt() {
        verifyReceipt { [weak self] result in
        switch result {
            case .success(receipt: let dict):
                guard let self = self else { return }
                if let receipt = dict["receipt"] as? [String: Any],
                    let inApps = receipt["in_app"] as? [[String: Any]],
                    let inApp = inApps.first,
                    let orderIPAID = inApp["original_transaction_id"] as? String {
                    let jsonString = self.convertDictionaryToJsonString(receipt)
                    self.chargeToGameWithOrderID(orderID: UUID().uuidString, orderIDIAP: orderIPAID, productID: self.packageSelected.productIDStore, dataReceipt: jsonString, packageID: self.packageSelected.packageID, transactionID: self.transactionID)
                } else {
                    STDAlertController.showAlertController(title: "Thông báo", message: "Đã xảy ra lỗi", nil)
                }
            break
            case .error(error: let error):
                STDAlertController.showAlertController(title: "Thông báo", message: error.localizedDescription, nil)
                break
            }
            
        }
        
    }
    
    var appStoreReceiptData: Data? {
        guard let receiptDataURL = Bundle.main.appStoreReceiptURL,
            let data = try? Data(contentsOf: receiptDataURL) else {
            return nil
        }
        return data
    }
    
    @objc func paymentTransactionUpdated(notification: Notification) {
        
        
    }
    
    
    private func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
        
        let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: kSecretKey)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: completion)
    }
    
    private func findProductWithPackageID(packageId: String) -> SKProduct? {
        guard let products = StoreKitManager.sharedInstance.products else {
            return nil
            
        }
        for product in products {
            if product.productIdentifier == packageId {
                return product
            }
        }
        return nil
    }
    
    private func purchaseProduct() {
        Indicator.sharedInstance.showIndicator()
        SwiftyStoreKit.purchaseProduct(productIdentifier, quantity: 1, atomically: true) { [weak self] result in
            Indicator.sharedInstance.hideIndicator()
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                self?.verifyReceipt()
            case .error(let error):
                var errorString = ""
                switch error.code {
                case .unknown: errorString =  "Lỗi không xác định. Vui lòng liên hệ bộ phận hỗ trợ"
                case .clientInvalid: errorString = "Không được phép thanh toán"
                case .paymentCancelled: errorString = "Đã hủy thanh toán"
                case .paymentInvalid: errorString = "Mã định danh mua hàng không hợp lệ"
                case .paymentNotAllowed: errorString = "Thiết bị không được phép thanh toán"
                case .storeProductNotAvailable: errorString = "Sản phẩm không có sẵn trong cửa hàng hiện tại"
                case .cloudServicePermissionDenied: errorString = "Truy cập vào dịch vụ đám mây không được phép"
                case .cloudServiceNetworkConnectionFailed: errorString = "Không thể kết nối với mạng"
                case .cloudServiceRevoked: errorString = "Người dùng đã thu hồi quyền sử dụng dịch vụ đám mây này"
                default:
                    errorString = (error as NSError).localizedDescription
                }
                STDAlertController.showAlertController(title: "Thông báo", message: errorString, nil)
            }
        }
        
    }
    
    
    //MARK - API
    
    private func createTransactionWithPackageID(packageId: String) {
        
        guard let accessToken = STDAppDataSingleton.sharedInstance.userProfileModel?.accessToken else {
            STDAlertController.showAlertController(title: "Thông báo", message: "Đăng nhập để tiếp tục", nil)
            Indicator.sharedInstance.hideIndicator()
            return
        }
        
        guard let urlConfig = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLSynQuickDevice, urlConfig.count > 0 else {
            return
        }
        let currentTime = STDAppDataSingleton.sharedInstance.getTimeCurrent()
        let plainText = "\(accessToken)\(packageId)\(UIDevice.current.identifierForVendor?.uuidString ?? "")\(currentTime)"
        let sign = STDAppDataSingleton.sharedInstance.hmac(plainText: plainText, key: kSDKSecretKey)
        let params = ["DeviceID": UIDevice.current.identifierForVendor?.uuidString ?? "",
                      "AccessToken": accessToken,
                      "Sign":sign,
                      "Time":currentTime,
                      "PackageID": packageId];
        STDNetworkController.shared.createTransaction(params: params) { [weak self] (transactionID, error) in
            if let transactionID = transactionID {
                self?.transactionID = transactionID
                self?.purchaseProduct()
            } else {
                STDAlertController.showAlertController(title: "Thông báo", message: error, nil)
                Indicator.sharedInstance.hideIndicator()
            }
        }
    }
    
    func purchaseProductWithPackage(packageId: String) {
        StoreKitManager.sharedInstance.validateProductIdentifiers()
        productIdentifier = packageId
        if SKPaymentQueue.canMakePayments() == false {
            STDAlertController.showAlertController(title: "Thông báo", message: "Lỗi khi mua sản phẩm!", nil)
            Indicator.sharedInstance.hideIndicator()
            return
        }
        
        guard let accessToken = STDAppDataSingleton.sharedInstance.userProfileModel?.accessToken else {
            STDAlertController.showAlertController(title: "Thông báo", message: "Đăng nhập để tiếp tục", nil)
            Indicator.sharedInstance.hideIndicator()
            return
        }
        
        guard let urlConfig = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLSynQuickDevice, urlConfig.count > 0 else {
            Indicator.sharedInstance.hideIndicator()
            return
        }
        let currentTime = STDAppDataSingleton.sharedInstance.getTimeCurrent()
        let plainText = "\(accessToken)\(currentTime)"
        let sign = STDAppDataSingleton.sharedInstance.hmac(plainText: plainText, key: kSDKSecretKey)
        let params = ["DeviceID": UIDevice.current.identifierForVendor?.uuidString ?? "",
                      "AccessToken": accessToken,
                      "Sign":sign,
                      "Time":currentTime];
        Indicator.sharedInstance.showIndicator()
        STDNetworkController.shared.getListDefinePackage(params: params) { [weak self] (packages, error) in
            if let packages = packages {
//                let ids = packages.map{$0.productIDStore}
//                StoreKitManager.sharedInstance.setProductIdentifier(ids)
                for package in packages {
                    if package.packageID == packageId {
                        self?.packageSelected = package
                        self?.productIdentifier = package.productIDStore
                        self?.createTransactionWithPackageID(packageId: packageId)
                    }
                }
            } else {
                Indicator.sharedInstance.hideIndicator()
                STDAlertController.showAlertController(title: "Thông báo", message: error, nil)
            }
        }
    }
    
    private func chargeToGameWithOrderID(orderID: String, orderIDIAP: String, productID: String, dataReceipt: String, packageID: String, transactionID: String) {
        let orderID = "game556_784_abc"
        guard let accessToken = STDAppDataSingleton.sharedInstance.userProfileModel?.accessToken else {
            STDAlertController.showAlertController(title: "Thông báo", message: "Đăng nhập để tiếp tục", nil)
            Indicator.sharedInstance.hideIndicator()
            return
        }
        
        guard let urlConfig = STDAppDataSingleton.sharedInstance.urlsConfig?.uRLIAPChargeToGame, urlConfig.count > 0 else {
            Indicator.sharedInstance.hideIndicator()
            return
        }
        let currentTime = STDAppDataSingleton.sharedInstance.getTimeCurrent()
        let plainText = "\(accessToken)\(orderID)\(orderIDIAP)\(productID)\(currentTime)"
        let sign = STDAppDataSingleton.sharedInstance.hmac(plainText: plainText, key: kSDKSecretKey)
        let params = ["DeviceID": UIDevice.current.identifierForVendor?.uuidString ?? "",
                      "AccessToken": accessToken,
                      "Sign": sign,
                      "Time": currentTime,
                      "DataReceipt": dataReceipt,
                      "OrderIDIAP": orderIDIAP,
                      "PackageID": packageID,
                      "OrderID": orderID,
                      "ProductID": productID,
                      "TransactionID": transactionID,
                      "ServerID":"s1"];
        
        STDNetworkController.shared.chargeToGame(params: params) { (paymentModel, error) in
            if paymentModel != nil {
                STDAlertController.showAlertController(title: "Thông báo", message: "Thanh toán thành công", nil)
            } else {
                STDAlertController.showAlertController(title: "Thông báo", message: error, nil)
                
            }
            Indicator.sharedInstance.hideIndicator()
        }
    }
    
}
