//
//  STDAppDataSingleton.swift
//  SDKGame
//
//  Created by Fu on 3/5/20.
//  Copyright © 2020 PiPyL. All rights reserved.
//

import UIKit
import CommonCrypto
//import Firebase
//import FirebaseDatabase

enum Defaults {
    static func set(_ object: Any, forKey defaultName: String) {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(object, forKey:defaultName)
        defaults.synchronize()
        
    }
    static func object(forKey key: String) -> AnyObject! {
        let defaults: UserDefaults = UserDefaults.standard
        return defaults.object(forKey: key) as AnyObject?
    }
}

class STDAppDataSingleton: NSObject {
    
    @objc static let sharedInstance = STDAppDataSingleton()
    
    @objc var urlsConfig: STDURLModel?
    var serverID: String?
    var orderID: String = ""
    var debugsString: String = ""
    var isEnableDebugs: Bool = false
    var lastUserName: String {
        get {
            return UserDefaults.standard.object(forKey: "kLastUserName") as? String ?? ""
        }
        set(userName) {
            UserDefaults.standard.set(userName, forKey: "kLastUserName")
        }
    }
    var timeCurrentFormatter: DateFormatter!
        
    private override init() {
        super.init()
        
        self.serverID = "s1";
        timeCurrentFormatter = DateFormatter()
        timeCurrentFormatter.dateFormat = "yyyyMMddHHmmss"
    }
    
    func getTimeCurrent() -> String {
        timeCurrentFormatter.string(from: Date())
    }
    
    @objc func hmac(plainText: String, key: String) -> String {
        let encoding = String.Encoding.ascii
        guard let str = plainText.cString(using: encoding),
            let keyStr = key.cString(using: encoding) else {
            return ""
        }
        
        let strLen = Int(plainText.lengthOfBytes(using: encoding))
        let keyLen = Int(key.lengthOfBytes(using: encoding))
        let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let algorithm = CCHmacAlgorithm(kCCHmacAlgSHA256)
        CCHmac(algorithm, keyStr, keyLen, str, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        let digest = String(hash).lowercased()
        result.deallocate()
        
        return digest 
    }
    
    func getIPAddress() -> String? {
        var address : String?
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        return address
    }
    
    //MARK: - UserDefaults
    
    var isSecondTimePlayNow: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "IsFirstPLayNow")
        }
        
        set(value) {
            UserDefaults.standard.set(value, forKey: "IsFirstPLayNow")
        }
    }
    
    @objc var userProfileModel: STDUserModel? {
        get {
            if let userProfileDict = Defaults.object(forKey: "UserProfileModel") as? [String : Any], userProfileDict.count != 0 {
                return STDUserModel.init(fromDictionary: userProfileDict)
            }
    
            return nil
        }
        
        set(userProfileModel) {
            if userProfileModel != nil {
                let dict = userProfileModel!.toDictionary()
                Defaults.set(dict, forKey: "UserProfileModel")
            } else {
                Defaults.set([:], forKey: "UserProfileModel")
            }
        }
    }

}
