//
//  ValidationManager.swift
//  Amistos
//
//  Created by chawtech solutions on 3/26/18.
//  Copyright © 2018 chawtech solutions. All rights reserved.
//

import UIKit

class ValidationManager: NSObject {

    class func validatePassword(password:String) -> Int {
        let characterSet = NSCharacterSet.whitespaces
        let range = password.rangeOfCharacter(from: characterSet)
        
        if range == nil {
            if password.characters.count >= kPasswordMinimumLength  {
                return 2
            } else {
                return 0
            }
        } else {
            return 1
        }
    }
    
    class func validateEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    class func validateUserFullName(name:String) -> Bool {
        let trimmedName = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmedName.characters.count < 2 {
            return false
        } else {
            let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ. ")
            if trimmedName.rangeOfCharacter(from: characterset.inverted) != nil {
                return false
            } else {
                return true
            }
        }
    }
    
    class func validatePhone(no:String) -> Bool {
        let mobileRegEx = NSString(format:"[0-9]{%d}",kPhoneNumberMaximumLength) as String
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", mobileRegEx)
        return phoneTest.evaluate(with: no)
    }
    
    class func validateFieldForEmpty(text:String) -> Bool {
        let trimmedText = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmedText.characters.count == 0 {  
            return false
        } else {
            return true
        }
    }
    
    class func validateAlphanumericAndLength(text:String,length: Int) -> Bool {
        let trimmedText = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmedText.characters.count < length {
            return false
        } else {
            let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789 ")
            if trimmedText.rangeOfCharacter(from: characterset.inverted) != nil {
                return false
            } else {
                return true
            }
        }
    }

}
