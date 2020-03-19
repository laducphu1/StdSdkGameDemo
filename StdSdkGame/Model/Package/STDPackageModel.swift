//
//  STDPackageModel.swift
//  SDKGame
//
//  Created by Fu on 3/5/20.
//  Copyright © 2020 PiPyL. All rights reserved.
//

import Foundation


class STDPackageModel : NSObject, NSCoding{
    var money : Int = 0
    var packageID : String = ""
    var productIDStore : String = ""

    init(fromDictionary dictionary: [String:Any]){
        money = dictionary["Money"] as? Int ?? 0
        packageID = dictionary["PackageID"] as? String ?? ""
        productIDStore = dictionary["ProductIDStore"] as? String ?? ""
    }
    
    override init() {
        super.init()
    }

    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        dictionary["PackageID"] = packageID
        dictionary["Money"] = money
        dictionary["ProductIDStore"] = productIDStore

        return dictionary
    }

    @objc required init(coder aDecoder: NSCoder)
    {
         money = aDecoder.decodeObject(forKey: "Money") as? Int ?? 0
         packageID = aDecoder.decodeObject(forKey: "PackageID") as? String ?? ""
         productIDStore = aDecoder.decodeObject(forKey: "ProductIDStore") as? String ?? ""
    }

    @objc func encode(with aCoder: NSCoder)
    {
        aCoder.encode(packageID, forKey: "PackageID")
        aCoder.encode(money, forKey: "Money")
        aCoder.encode(productIDStore, forKey: "ProductIDStore")
    }

}
