//
//  STDURLModel.swift
//  SDKGame
//
//  Created by Fu on 3/5/20.
//  Copyright © 2020 PiPyL. All rights reserved.
//

import Foundation


class STDURLModel : NSObject, NSCoding{

    var domainAPI : String = ""
    var uRLFBAccessToken : String = ""
    var uRLGGAccessToken : String = ""
    var uRLGetUserToken : String = ""
    var uRLIAPChargeToGame : String = ""
    var uRLIAPCreateTrans : String = ""
    var uRLIAPListDefinePackage : String = ""
    var uRLLogin : String = ""
    var uRLLoginQuickDevice : String = ""
    var uRLLogoutToken : String = ""
    var uRLLostPassword : String = ""
    var uRLRegister : String = ""
    var uRLSignInApple : String = ""
    var uRLSynQuickDevice : String = ""

    init(fromDictionary dictionary: [String:Any]){
        domainAPI = dictionary["DomainAPI"] as? String ?? ""
        uRLFBAccessToken = dictionary["URL_FBAccessToken"] as? String ?? ""
        uRLGGAccessToken = dictionary["URL_GGAccessToken"] as? String ?? ""
        uRLGetUserToken = dictionary["URL_GetUserToken"] as? String ?? ""
        uRLIAPChargeToGame = dictionary["URL_IAP_ChargeToGame"] as? String ?? ""
        uRLIAPCreateTrans = dictionary["URL_IAP_CreateTrans"] as? String ?? ""
        uRLIAPListDefinePackage = dictionary["URL_IAP_DefinePackage"] as? String ?? ""
        uRLLogin = dictionary["URL_Login"] as? String ?? ""
        uRLLoginQuickDevice = dictionary["URL_LoginQuickDevice"] as? String ?? ""
        uRLLogoutToken = dictionary["URL_LogoutToken"] as? String ?? ""
        uRLLostPassword = dictionary["URL_LostPassword"] as? String ?? ""
        uRLRegister = dictionary["URL_Register"] as? String ?? ""
        uRLSignInApple = dictionary["URL_SignInApple"] as? String ?? ""
        uRLSynQuickDevice = dictionary["URL_SynQuickDevice"] as? String ?? ""
    }

    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        dictionary["DomainAPI"] = domainAPI
        dictionary["URL_FBAccessToken"] = uRLFBAccessToken
        dictionary["URL_GGAccessToken"] = uRLGGAccessToken
        dictionary["URL_GetUserToken"] = uRLGetUserToken
        dictionary["URL_IAP_ChargeToGame"] = uRLIAPChargeToGame
        dictionary["URL_IAP_CreateTrans"] = uRLIAPCreateTrans
        dictionary["URL_IAP_DefinePackage"] = uRLIAPListDefinePackage
        dictionary["URL_Login"] = uRLLogin
        dictionary["URL_LoginQuickDevice"] = uRLLoginQuickDevice
        dictionary["URL_LogoutToken"] = uRLLogoutToken
        dictionary["URL_LostPassword"] = uRLLostPassword
        dictionary["URL_Register"] = uRLRegister
        dictionary["URL_SignInApple"] = uRLSignInApple
        dictionary["URL_SynQuickDevice"] = uRLSynQuickDevice

        return dictionary
    }

    @objc required init(coder aDecoder: NSCoder)
    {
         domainAPI = aDecoder.decodeObject(forKey: "DomainAPI") as? String ?? ""
         uRLFBAccessToken = aDecoder.decodeObject(forKey: "URL_FBAccessToken") as? String ?? ""
         uRLGGAccessToken = aDecoder.decodeObject(forKey: "URL_GGAccessToken") as? String ?? ""
         uRLGetUserToken = aDecoder.decodeObject(forKey: "URL_GetUserToken") as? String ?? ""
         uRLIAPChargeToGame = aDecoder.decodeObject(forKey: "URL_IAP_ChargeToGame") as? String ?? ""
         uRLIAPCreateTrans = aDecoder.decodeObject(forKey: "URL_IAP_CreateTrans") as? String ?? ""
         uRLIAPListDefinePackage = aDecoder.decodeObject(forKey: "URL_IAP_DefinePackage") as? String ?? ""
         uRLLogin = aDecoder.decodeObject(forKey: "URL_Login") as? String ?? ""
         uRLLoginQuickDevice = aDecoder.decodeObject(forKey: "URL_LoginQuickDevice") as? String ?? ""
         uRLLogoutToken = aDecoder.decodeObject(forKey: "URL_LogoutToken") as? String ?? ""
         uRLLostPassword = aDecoder.decodeObject(forKey: "URL_LostPassword") as? String ?? ""
         uRLRegister = aDecoder.decodeObject(forKey: "URL_Register") as? String ?? ""
         uRLSignInApple = aDecoder.decodeObject(forKey: "URL_SignInApple") as? String ?? ""
         uRLSynQuickDevice = aDecoder.decodeObject(forKey: "URL_SynQuickDevice") as? String ?? ""
    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
    {
        aCoder.encode(domainAPI, forKey: "DomainAPI")
        aCoder.encode(uRLFBAccessToken, forKey: "URL_FBAccessToken")
        aCoder.encode(uRLGGAccessToken, forKey: "URL_GGAccessToken")
        aCoder.encode(uRLGetUserToken, forKey: "URL_GetUserToken")
        aCoder.encode(uRLIAPChargeToGame, forKey: "URL_IAP_ChargeToGame")
        aCoder.encode(uRLIAPCreateTrans, forKey: "URL_IAP_CreateTrans")
        aCoder.encode(uRLIAPListDefinePackage, forKey: "URL_IAP_DefinePackage")
        aCoder.encode(uRLLogin, forKey: "URL_Login")
        aCoder.encode(uRLLoginQuickDevice, forKey: "URL_LoginQuickDevice")
        aCoder.encode(uRLLogoutToken, forKey: "URL_LogoutToken")
        aCoder.encode(uRLLostPassword, forKey: "URL_LostPassword")
        aCoder.encode(uRLRegister, forKey: "URL_Register")
        aCoder.encode(uRLSignInApple, forKey: "URL_SignInApple")
        aCoder.encode(uRLSynQuickDevice, forKey: "URL_SynQuickDevice")
    }
}
