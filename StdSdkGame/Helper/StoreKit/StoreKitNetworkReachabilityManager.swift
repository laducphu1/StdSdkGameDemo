//
//  NetworkReachabilityManager.swift
//  Yoga Studio TV
//
//  Created by Paul Bonneville on 10/29/15.
//  Copyright © 2015 Tack Mobile. All rights reserved.
//

import UIKit

class StoreKitNetworkReachabilityManager: NSObject {
	
	enum NetworkStatus: String {
		case Available, NotAvailable, Unknown
		
		var description: String {
			switch self {
			case .Available: return "Available"
			case .NotAvailable: return "NotAvailable"
			case .Unknown: return "Unknown"
			}
		}
	}
	
	enum ConnectionType: String {
		case Wifi, Cellular, WWAN, NotAvailable, Unknown
		
		var description: String {
			switch self {
			case .Wifi: return "Wifi"
			case .Cellular: return "Cellular"
			case .WWAN: return "WWAN"
			case .NotAvailable: return "NotAvailable"
			case .Unknown: return "Unknown"
			}
		}
	}
	
	static let sharedInstance = StoreKitNetworkReachabilityManager()
	
	static let USERINFO_KEY_NETWORK_STATUS = "networkStatus"
	static let USERINFO_KEY_CONNECTION_TYPE = "connectionType"
	static let NOTIFICATION_NETWORK_REACHABILITY_CHANGE = "NOTIFICATION_NETWORK_REACHABILITY_CHANGE"
	
	fileprivate var ENABLE_CONSOLE_MESSAGES = true
	
	var reachability: Reachability?
	var networkStatus: NetworkStatus
	var connectionType: ConnectionType
	
	override init() {
		networkStatus = .Unknown
		connectionType = .Unknown
		super.init()
		
		consoleLog(#function, message: "INITING NETWORK REACHBILITY MANAGER")
		
		reachability = Reachability.init()
		NotificationCenter.default.addObserver(self,
		                                       selector: #selector(StoreKitNetworkReachabilityManager.reachabilityChanged(_:)),
		                                       name: ReachabilityChangedNotification,
		                                       object: self.reachability!)
		do {
			try reachability!.startNotifier()
			consoleLog(#function, message: "NETWORK REACHABILITY NOTIFIER STARTED")
			
			// Send out notification of initial network status
			processReachability(reachability!)
		} catch {
			consoleLog(#function, message: "UNABLE TO START NETWORK REACHABILITY: \(error)")
		}
//		do {
//			reachability = try NetworkReachability.init()
//			
//			NotificationCenter.default.addObserver(self,
//				selector: #selector(StoreKitNetworkReachabilityManager.reachabilityChanged(_:)),
//				name: NSNotification.Name(rawValue: ReachabilityChangedNotification),
//				object: self.reachability!)
//			
//			do {
//				try reachability!.startNotifier()
//				consoleLog(#function, message: "NETWORK REACHABILITY NOTIFIER STARTED")
//				
//				// Send out notification of initial network status
//				processReachability(reachability!)
//			} catch {
//				consoleLog(#function, message: "UNABLE TO START NETWORK REACHABILITY: \(error)")
//			}
//			
//		} catch {
//			consoleLog(#function, message: "UNABLE TO INITIALIZE NETWORK REACHABILITY: \(error)")
//		}
	}
	
	@objc func reachabilityChanged(_ note: Notification) {
		let reachability = note.object as! Reachability
		processReachability(reachability)
	}

	func processReachability(_ reachabilityObject: Reachability) {
		let message = "NETWORK REACHABILITY CHANGED:"
		if reachabilityObject.isReachable {
			networkStatus = .Available
			
			if reachabilityObject.isReachableViaWiFi {
				consoleLog(#function, message: "\(message) REACHABLE VIA WIFI")
				connectionType = .Wifi
			} else if reachabilityObject.isReachableViaWWAN {
				consoleLog(#function, message: "\(message) REACHABLE VIA WWAN")
				connectionType = .WWAN
			} else {
				consoleLog(#function, message: "\(message) REACHABLE VIA CELLULAR")
				connectionType = .Cellular
			}
		} else {
			self.networkStatus = .NotAvailable
			self.connectionType = .NotAvailable
			consoleLog(#function, message: "\(message) NOT REACHABLE")
		}
		
		NotificationCenter.default.post(Notification(
			name: Notification.Name(rawValue: StoreKitNetworkReachabilityManager.NOTIFICATION_NETWORK_REACHABILITY_CHANGE),
			object: self,
			userInfo: [StoreKitNetworkReachabilityManager.USERINFO_KEY_NETWORK_STATUS : networkStatus.description, StoreKitNetworkReachabilityManager.USERINFO_KEY_CONNECTION_TYPE : connectionType.description]))
	}
	
	fileprivate func consoleLog(_ method:String, message: String = "") {
		if ENABLE_CONSOLE_MESSAGES == true {
			print("🔵[\(#file.components(separatedBy: "/").last!): \(method)] \(message)")
		}
	}
}
