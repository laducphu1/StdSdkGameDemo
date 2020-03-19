//
//  STDString.swift
//  SDKGame
//
//  Created by Fu on 3/6/20.
//  Copyright © 2020 PiPyL. All rights reserved.
//

import UIKit
import CommonCrypto

extension String {
    
    static func generateCaptcha() -> String {
        var captcha = ""
        captcha = "\(captcha)\(Int.random(in: 0 ... 9))"
        captcha = "\(captcha)\(Int.random(in: 0 ... 9))"
        captcha = "\(captcha)\(Int.random(in: 0 ... 9))"
        return captcha
    }
    
    static func getDataReceipt() -> String {
        
        return ""
    }
    
    func isValidPhoneNumber() -> Bool {
        
        let characterSet = CharacterSet(charactersIn: "+0123456789")
        if rangeOfCharacter(from: characterSet.inverted) != nil {
            return false
        }
        let text = replacingOccurrences(of: "+", with: "")
        if text.hasPrefix("84") {
            if text.count != 11 {
                return false
            }
        } else if text.count != 10 {
            return false
        }
        return true;
    }
    
    func isValidEmail()-> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func userNameIsValid() -> Bool {
        let characterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789")
        if rangeOfCharacter(from: characterSet.inverted) != nil {
            return false
        }
        return true;
    }
    
    func isOnlyLetterAndNumber() -> Bool {
        let regex = try? NSRegularExpression(pattern: ".*[^A-Za-z0-9].*")

        if regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) != nil {
            return false
        }
        return true
    }
    
    func isValidPassword() -> Bool {
        let passRegex = "^(?=.*[0-9])(?=.*[a-zA-Z])([\\s\\S]+)$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", passRegex)
        return emailTest.evaluate(with: self)
    }
    
    func MD5String() -> String {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, self, CC_LONG(lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate()
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        return hexString
    }
    
}
