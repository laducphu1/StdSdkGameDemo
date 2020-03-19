//
//  STDResultPaymentModel.swift
//  SDKGame
//
//  Created by Fu on 3/5/20.
//  Copyright © 2020 PiPyL. All rights reserved.
//

import Foundation


class STDResultPaymentModel : NSObject, NSCoding {

    var amount : Int = 0
    var orderID : String = ""
    var other : String = ""
    var packageID : String = ""
    var time : String = ""
    var timeSDKServer : String = ""

    init(fromDictionary dictionary: [String:Any]){
        orderID = dictionary["OrderID"] as? String ?? ""
        amount = dictionary["Amount"] as? Int ?? 0
        other = dictionary["Other"] as? String ?? ""
        packageID = dictionary["PackageID"] as? String ?? ""
        time = dictionary["Time"] as? String ?? ""
        timeSDKServer = dictionary["TimeSDKServer"] as? String ?? ""
    }

    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        dictionary["OrderID"] = orderID
        dictionary["Amount"] = amount
        dictionary["Other"] = other
        dictionary["PackageID"] = packageID
        dictionary["Time"] = time
        dictionary["TimeSDKServer"] = timeSDKServer

        return dictionary
    }

    @objc required init(coder aDecoder: NSCoder)
    {
         amount = aDecoder.decodeObject(forKey: "Amount") as? Int ?? 0
         orderID = aDecoder.decodeObject(forKey: "OrderID") as? String ?? ""
         other = aDecoder.decodeObject(forKey: "Other") as? String ?? ""
         packageID = aDecoder.decodeObject(forKey: "PackageID") as? String ?? ""
         time = aDecoder.decodeObject(forKey: "Time") as? String ?? ""
         timeSDKServer = aDecoder.decodeObject(forKey: "TimeSDKServer") as? String ?? ""
    }

    @objc func encode(with aCoder: NSCoder)
    {
        aCoder.encode(orderID, forKey: "OrderID")
        aCoder.encode(amount, forKey: "Amount")
        aCoder.encode(other, forKey: "Other")
        aCoder.encode(packageID, forKey: "PackageID")
        aCoder.encode(time, forKey: "Time")
        aCoder.encode(timeSDKServer, forKey: "TimeSDKServer")
    }
}

