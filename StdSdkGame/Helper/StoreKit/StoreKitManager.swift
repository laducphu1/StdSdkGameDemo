//
//  StoreKitManager.swift
//  YogaDatabase
//
//  Created by Paul Bonneville on 3/1/16.
//
//

import Foundation
import StoreKit

@objc open class StoreKitManager: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
	
	// MARK: - Variables
	
	@objc static let sharedInstance = StoreKitManager()
	
	static let NOTIFICATION_PRODUCT_VALIDATION_COMPLETE = "NOTIFICATION_PRODUCT_VALIDATION_COMPLETE"
	
	@objc static let NOTIFICATION_PAYMENT_TRANSACTION_UPDATED = "NOTIFICATION_PAYMENT_TRANSACTION_UPDATED"
	static let USERINFO_KEY_PAYMENT_TRANSACTION = "paymentTransaction"
	
	fileprivate let USERDEFAULT_WWF_CONTENT_PURCHASED = "USERDEFAULT_WWF_CONTENT_PURCHASED"
	fileprivate let ENABLE_CONSOLE_MESSAGES = true
	
	let paymentQueue = SKPaymentQueue.default()
	let userDefaults = UserDefaults.standard
	
	var productsRequest: SKProductsRequest?
	@objc var products: [SKProduct]?
	
	var isNetworkAvailable = false
  
  @objc static let subscriptionDetailsText = NSLocalizedString("Yoga Studio Subscription Yoga Studio offers several subscription choices of various durations and pricing. These plans may include a weekly, monthly, and a yearly plan. All options give you same full access to Yoga Studio and all its features just at different duration levels. Once an option is selected you will be given a week free trial to use Yoga Studio. Once the trial comes to an end, your iTunes Account will be charged based on the subscription option selected. The subscription will automatically renew unless auto-renew is turned off at least 24-hours before the end of the current period. Your account will be charged for renewal within 24-hours prior to the end of the current period and identify the cost of the renewal. Subscriptions may be managed by going to your Apple ID, accessing user Account Settings within your iOS device after a selection or purchase. Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable.", comment: "Subscription details message")
	
	// MARK: - Initializers
	
	override init() {
		super.init()
		consoleLog(#function, message: "STOREKITMANAGER INIT")
		
		// Listen for network availablility changes
		NotificationCenter.default.addObserver(self, selector: #selector(StoreKitManager.networkAvailabilityChanged(_:)), name: NSNotification.Name(rawValue: StoreKitNetworkReachabilityManager.NOTIFICATION_NETWORK_REACHABILITY_CHANGE), object: nil)
		
		// Fire up Reachability manager
		_ = StoreKitNetworkReachabilityManager.sharedInstance
		
		// Start watching StoreKit transactions
		paymentQueue.add(self)
	}
	
	// MARK: - Network availability changes
	
	/**
	Notification event handler for changes in network availability from the NetworkReachabilityManager
	
	- parameter notification: NSNotification with userdata on network connection
	*/
	@objc func networkAvailabilityChanged(_ notification: Notification) {
		let networkAvialable = notification.userInfo![StoreKitNetworkReachabilityManager.USERINFO_KEY_NETWORK_STATUS]
		consoleLog(#function, message: "NETWORK AVAILABILITY CHANGE: \(networkAvialable!)")
		isNetworkAvailable = (StoreKitNetworkReachabilityManager.NetworkStatus.Available.description == networkAvialable as! String)
		
		if isNetworkAvailable == true {
			validateProductIdentifiers()
		}
	}
	
	// MARK: - Custom methods
	
  /**
   Ensures that all of our locally stored product identifiers are valid and, if they are, sets the local products variable
   with the valid SKProducts. Response is handled by SKPaymentTransactionObserver protocol implementation paymentQueue:updatedTransactions
   */
  func validateProductIdentifiers() {
    consoleLog(#function)
    
   //  Validate that productsRequest is nilled out first
//    productsRequest = nil
//
//    // Veryify that getProductIdentifiers returns a valid list and this isn't the crash
//    if let productIDs = getProductIdentifiers() {
//      let productIDSet = Set(productIDs)
//      productsRequest = SKProductsRequest(productIdentifiers: productIDSet)
//      productsRequest?.delegate = self
//      productsRequest?.start()
//    }
  }
	
    func setProductIdentifier(_ ids: [String]) {
        let productIDSet = Set(ids)
        productsRequest = SKProductsRequest(productIdentifiers: productIDSet)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
	/**
	Loads the local product identifiers we have stored in a local plist
	
	- returns: An array of product identifier strings
	*/
	func getProductIdentifiers() -> [String]? {
//		let productIdentifiersURL = Bundle.main.url(forResource: "ys_storekit_product_identifiers", withExtension: "plist")
//		let productIdentifiers = NSArray(contentsOf: productIdentifiersURL!)
//
//        consoleLog(#function, message: "productIdentifiers:: \(productIdentifiers!)")
//
//		return productIdentifiers as? [String]
        return ["test_product_1"];
	}
	
	/**
	Formats the price of a product based on the product's price locale as determined by the app store the purchase
	is being made through
	
	- parameter product: The SKProduct you need the localized price string for
	
	- returns: A string that represents the localized price
	*/
	func formattedPriceForProduct(_ product: SKProduct) -> String {
		let priceFormatter = NumberFormatter()
		priceFormatter.numberStyle = NumberFormatter.Style.currency
		priceFormatter.locale = product.priceLocale
		return priceFormatter.string(from: product.price)!
	}
	
	/**
	Ensures that the current user is allowed to make purchases with this device and itunes account
	
	- returns: Boolean if YES/true if user can make purchases
	*/
	func userCanMakePayments() -> Bool {
		let returnValue = SKPaymentQueue.canMakePayments()
		let message = (returnValue ==  true) ? "USER CAN MAKE PURCHASES" : "USER CANNOT MAKE PURCHASES"
		consoleLog(#function, message: message)
		return returnValue
	}
	
	/**
	Submits a payment to the payment queue
	
	- parameter product: The SKProduct that is to be submitted for purchasing
	*/
	
	/**
	Submits a payment to the payment queue
	
	- parameter product: The SKProduct that is to be submitted for purchasing
	
	- returns: TRUE is the user has an Internet connection and can make pruchases, otherwise FALSE
	*/
	@objc func purchaseProduct(_ product: SKProduct) -> Bool {
		let message = "PURCHASE PRODUCT: \(product.localizedTitle)"
		consoleLog(#function, message: message)

		if userCanMakePayments() == true {
			if isNetworkAvailable == true {
				let payment = SKMutablePayment(product: product)
				paymentQueue.add(payment)
				return true
			} else {
				presentAlertControllerWithTitle(NSLocalizedString("Unable to Reach the App Store", comment: "Unable to reach app store alert title"),
					message: NSLocalizedString("We are unable to connect to the Apple App Store for your In-App purchase. Please check your connection and try again.", comment: "Unable to reach app store alert message"))
			}
		} else {
			presentAlertControllerWithTitle(NSLocalizedString("Unable to Make Purchases", comment: "User can't make purchases alert title"),
				message: NSLocalizedString("You are not authorized to make purchases on this device.", comment: "User can't make purchases alert message"))
		}
		
		return false
	}
	
	/**
	Checks to see if the WWF content has been successfully purchased via In-App purchase
	
	- returns: Boolean of true if the content was purchased
	*/
	func wwfContentPurchased() -> Bool {
		let returnValue = userDefaults.bool(forKey: USERDEFAULT_WWF_CONTENT_PURCHASED)
		let message = (returnValue ==  true) ? "USER HAS PURCHASED WWF CONTENT" : "USER HAS NOT PURCHASED WWF CONTENT"
		consoleLog(#function, message: message)
		return returnValue
	}
	
	/**
	Restores completed product purchases
	*/
	@objc func restoreCompletedTransactions() {
		consoleLog(#function, message: "RESTORING PREVIOUS PURCHASES")
		
		// Don't restore purchases if this user is not authorized to make purchases
		if userCanMakePayments() == true {
			if isNetworkAvailable == true {
				paymentQueue.restoreCompletedTransactions()
			} else {
				presentAlertControllerWithTitle(NSLocalizedString("Unable to Reach the App Store", comment: "Unable to reach app store alert title"),
					message: NSLocalizedString("We are unable to connect to the Apple App Store for your In-App purchase. Please check your connection and try again.", comment: "Unable to reach app store alert message"))
			}
		} else {
			presentAlertControllerWithTitle(NSLocalizedString("Unable to Restore Purchases", comment: "Restore Purchases alert title"),
				message: NSLocalizedString("You are not authorized to make purchases on this device. We are unable to restore previous purchases.", comment: "Restore Purchases alert message"))
		}
	}
	
	// MARK: - SKProductsRequestDelegate protocol method
	
	open func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		consoleLog(#function)
		products = response.products
		
		NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: StoreKitManager.NOTIFICATION_PRODUCT_VALIDATION_COMPLETE), object: self))
		
		for product in products! {
			consoleLog(#function, message: "\nSTOREKIT PRODUCT\nTitle: \(product.localizedTitle)\nDescription: \(product.localizedDescription)\nPrice: \(formattedPriceForProduct(product))")
		}
		
		// Handle any invalid product identifiers.
		for invalidIdentifier in response.invalidProductIdentifiers {
			consoleLog(#function, message: "INVALID STOREKIT IDENTIFIER: \(invalidIdentifier)")
		}
	}
	
	
	open func request(_ request: SKRequest, didFailWithError error: Error) {
		consoleLog(#function, message: error.localizedDescription)
	}
	
	// MARK: - SKPaymentTransactionObserver protocol methods
	
	// Tells an observer that one or more transactions have been updated.
	open func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		print("PAYMENT QUEUE: updatedTransactions")
		
		var message = ""
		
		for (index, transaction) in transactions.enumerated() {
			switch (transaction.transactionState) {
			case .purchasing:
				message = "\(index). Purchasing"
			case .deferred:
				message = "\(index). Deferred"
			case .failed:
				let baseMessage = "Transaction Failed:"
				switch(transaction.error!._code) {
				case SKError.unknown.rawValue:
					message = "\(baseMessage) Unknown"
				case SKError.clientInvalid.rawValue:
					message = "\(baseMessage) Invalid Client"
				case SKError.paymentCancelled.rawValue:
					message = "\(baseMessage) Payment Cancelled"
				case SKError.paymentInvalid.rawValue:
					message = "\(baseMessage) Payment Invalid"
				case SKError.paymentNotAllowed.rawValue:
					message = "\(baseMessage) Payment Not Allowed"
				case SKError.storeProductNotAvailable.rawValue:
					message = "\(baseMessage) Store Product Not Available"
				default:
					message = "\(baseMessage) Undefined Error"
				}
				
				presentAlertControllerWithTitle(NSLocalizedString("Unable to Complete Transaction", comment: "Unable to complete transaction error alert title"),
					message: NSLocalizedString("There was a problem completing the requested action for the following reason: \(message)", comment: "Unknown error alert message"))
				
				// Finish the transaction since we have just had our chance to deal with it
				paymentQueue.finishTransaction(transaction)
			case .purchased:
				message = "\(index). Purchased: \(transaction.payment.productIdentifier)"
				persistSuccessfulPurchaseTransaction(transaction)
			case .restored:
				message = "\(index). Restored: \(transaction.payment.productIdentifier)"
				persistSuccessfulPurchaseTransaction(transaction)
			}
			
			
			
			consoleLog(#function, message: message)
		}
	}
	
	// Tells an observer that one or more transactions have been removed from the queue.
	open func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
		// Your application does not typically need to implement this method but might implement it to update its own user interface
		// to reflect that a transaction has been completed.
		consoleLog(#function)
	}
	
	// Tells the observer that an error occurred while restoring transactions.
	open func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
//		presentAlertControllerWithTitle(NSLocalizedString("Purchases Not Restored", comment: "There was a problem trying to restore your purchases."),
//			message: NSLocalizedString("There was a problem trying to restore your purchases.", comment: "Purchase Restored alert message"))
        
//        presentAlertControllerWithTitle(NSLocalizedString("Warning", comment: "Your subscription has expired. Please renew."),
//                                        message: NSLocalizedString("Your subscription has expired. Please renew.", comment: "Your subscription has expired. Please renew."))
		consoleLog(#function, message: error.localizedDescription)
	}
	
	// Tells the observer that the payment queue has finished sending restored transactions.
	open func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
		consoleLog(#function)
	}
	
	// Tells the observer that the payment queue has updated one or more download objects.
	open func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
		// This method is called after all restorable transactions have been processed by the payment queue. Your application
		// is not required to do anything in this method.
		consoleLog(#function)
	}
	
	// MARK: - Utility methods
	
	/**
	Flags UserDefaults with an entry signifying that specific content has been successfully purchased
	
	- parameter transaction: The successful SKPaymentTransaction that has the info for the purchased product
	*/
	fileprivate func persistSuccessfulPurchaseTransaction(_ transaction: SKPaymentTransaction) {
         paymentQueue.finishTransaction(transaction)
        NotificationCenter.default.post(
        name: Notification.Name(rawValue: StoreKitManager.NOTIFICATION_PAYMENT_TRANSACTION_UPDATED),
        object: self,
        userInfo: [StoreKitManager.USERINFO_KEY_PAYMENT_TRANSACTION : transaction])
		switch(transaction.payment.productIdentifier) {
		case "ysearthmed":
			userDefaults.set(true, forKey: USERDEFAULT_WWF_CONTENT_PURCHASED)
			userDefaults.synchronize()

			paymentQueue.finishTransaction(transaction)
			
			// If this is a resotred purchase, let the user know.
			if transaction.transactionState == .restored {
				presentAlertControllerWithTitle(NSLocalizedString("Purchases Restored", comment: "Purchased Restored alert title"),
					message: NSLocalizedString("Your previous In-App purchases have been restored to this device.", comment: "Purchase Restored alert message"))
			}
			
			consoleLog(#function, message: "PURCHASE FOR PRODUCT IDENTIFIER RECORDED: \(transaction.payment.productIdentifier)")
		default:
			consoleLog(#function, message: "UNRECOGNIZED PRODUCT IDENTIFIER")
		}
	}
	
	/**
	Basic alert controller with title, message and OK button
	
	- parameter title:   Title for the alert controller
	- parameter message: Message for the alert controller
	*/
	func presentAlertControllerWithTitle(_ title: String = "Default Title", message: String = "Default message.") {
		let window = UIWindow(frame: UIScreen.main.bounds)
		window.rootViewController = UIViewController()
        window.windowLevel = UIWindow.Level.alert + 1
		
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Generic OK button on alert"), style: UIAlertAction.Style.cancel, handler: { (action) -> Void in
			window.isHidden = true
		}))
		
		window.makeKeyAndVisible()
		window.rootViewController?.present(alertController, animated: true, completion: nil)
	}
	
	fileprivate func consoleLog(_ method:String, message: String = "") {
		if ENABLE_CONSOLE_MESSAGES == true {
			print("⚪️[\(#file.components(separatedBy: "/").last!): \(method)] \(message)")
		}
	}
}
