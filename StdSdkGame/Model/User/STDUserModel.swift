//
//  STDUserModel.swift
//  SDKGame
//
//  Created by Fu on 3/5/20.
//  Copyright © 2020 PiPyL. All rights reserved.
//

import UIKit

import Foundation


@objc public class STDUserModel : NSObject, NSCoding {

    @objc public var accessToken : String = ""
    public var userID : String = ""
    public var avatar : String = ""
    public var birthDay : String = ""
    public var displayName : String = ""
    public var email : String = ""
    public var gender : String = ""
    public var primaryMobile : String = ""
    public var userName : String = ""
    public var isSyn : Bool = false


    override init() {
        super.init()
    }
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        accessToken = dictionary["AccessToken"] as? String ?? ""
        userID = dictionary["UserID"] as? String ?? ""
        avatar = dictionary["Avatar"] as? String ?? ""
        birthDay = dictionary["BirthDay"] as? String ?? ""
        displayName = dictionary["DisplayName"] as? String ?? ""
        email = dictionary["Email"] as? String ?? ""
        gender = dictionary["Gender"] as? String ?? ""
        primaryMobile = dictionary["PrimaryMobile"] as? String ?? ""
        userName = dictionary["UserName"] as? String ?? ""
        isSyn = dictionary["isSyn"] as? Bool ?? false
    }

    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        dictionary["AccessToken"] = accessToken
        dictionary["UserID"] = userID
        dictionary["Avatar"] = avatar
        dictionary["BirthDay"] = birthDay
        dictionary["DisplayName"] = displayName
        dictionary["Email"] = email
        dictionary["Gender"] = gender
        dictionary["PrimaryMobile"] = primaryMobile
        dictionary["UserName"] = userName
        dictionary["isSyn"] = isSyn

        return dictionary
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required public init(coder aDecoder: NSCoder)
    {
         accessToken = aDecoder.decodeObject(forKey: "AccessToken") as? String ?? ""
         userID = aDecoder.decodeObject(forKey: "UserID") as? String ?? ""
         avatar = aDecoder.decodeObject(forKey: "Avatar") as? String ?? ""
         birthDay = aDecoder.decodeObject(forKey: "BirthDay") as? String ?? ""
         displayName = aDecoder.decodeObject(forKey: "DisplayName") as? String ?? ""
         email = aDecoder.decodeObject(forKey: "Email") as? String ?? ""
         gender = aDecoder.decodeObject(forKey: "Gender") as? String ?? ""
         primaryMobile = aDecoder.decodeObject(forKey: "PrimaryMobile") as? String ?? ""
         userName = aDecoder.decodeObject(forKey: "UserName") as? String ?? ""
         isSyn = aDecoder.decodeObject(forKey: "isSyn") as? Bool ?? false
    }

    @objc public func encode(with aCoder: NSCoder)
    {
        aCoder.encode(accessToken, forKey: "AccessToken")
        aCoder.encode(userID, forKey: "UserID")
        aCoder.encode(avatar, forKey: "Avatar")
        aCoder.encode(birthDay, forKey: "BirthDay")
        aCoder.encode(displayName, forKey: "DisplayName")
        aCoder.encode(email, forKey: "Email")
        aCoder.encode(gender, forKey: "Gender")
        aCoder.encode(primaryMobile, forKey: "PrimaryMobile")
        aCoder.encode(userName, forKey: "UserName")
        aCoder.encode(isSyn, forKey: "isSyn")
    }
    
    @objc static public func logOutUser( _ success:(@escaping(_ isSuccess: Bool) -> Void)) {
        STDNetworkController.shared.logOutUser { (isSuccess, error) in
            if isSuccess {
                STDAppDataSingleton.sharedInstance.userProfileModel = nil
            }
            success(isSuccess)
        }
    }
}
