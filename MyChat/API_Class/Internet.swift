//
//  Internet.swift
//  Amistos
//
//  Created by chawtech solutions on 3/26/18.
//  Copyright © 2018 chawtech solutions. All rights reserved.
//

import Foundation
import SystemConfiguration

open class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}

class DataString: NSObject {
    
    var Number: String      = String()
    class func encodeText(_ plainString:String) -> String{
        let plainData = (plainString as NSString).data(using: String.Encoding.utf8.rawValue)
        let base64String = plainData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        //print(base64String) // bXkgcGxhbmkgdGV4dA==
        return base64String;
    }
    
    class func decodeText(_ base64String:String) -> String{
        let decodedData = Data(base64Encoded: base64String, options:NSData.Base64DecodingOptions(rawValue: 0))
        let decodedString = NSString(data: decodedData!, encoding: String.Encoding.utf8.rawValue)
        // print(decodedString) // my plain data
        return decodedString as! String;
    }
    
    class func encodeImage(_ base64String:String)-> Data {
        var decodedData:Data;
        do{
            decodedData = Data(base64Encoded: base64String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
            return decodedData;
        }catch let error as NSError {
            return decodedData;
        }
        
    }
    
}

class DateTime: NSObject {
    class func DateTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm"
        return formatter.string(from: date)
    }
    
   class func convertDateFormaterForWebService(_ dateString: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
        let date = dateFormatter.date(from: dateString)
        
        dateFormatter.dateFormat = "dd MMM YY"
        return dateFormatter.string(from: date!)
        
    }
    
    //get day name using date
    class func getDayOfWeek(_ today:String)->String {
        
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm"
        let todayDate = formatter.date(from: today)!
        let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let myComponents = (myCalendar as NSCalendar).components(.weekday, from: todayDate)
        let weekDay = myComponents.weekday!
        
        var day = ""
        switch String(describing: weekDay) {
        case "1":
            day = "Sun"
            break
        case "2":
            day = "Mon"
            break
        case "3":
            day = "Tue"
            break
        case "4":
            day = "Wed"
            break
        case "5":
            day = "Thu"
            break
        case "6":
            day = "Fri"
            break
        case "7":
            day = "Sat"
            break
        default:
            day = ""
        }
        return day
    }
}
