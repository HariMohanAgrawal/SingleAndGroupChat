//
//  Constants.swift
//  Amistos
//
//  Created by chawtech solutions on 3/26/18.
//  Copyright © 2018 chawtech solutions. All rights reserved.
//


import UIKit
import MBProgressHUD  
import SDWebImage
import AVFoundation
import FirebaseInstanceID

let screenSize = UIScreen.main.bounds
let screenWidth = screenSize.width
let screenHeight = screenSize.height
let window = UIApplication.shared.keyWindow!

let IS_IPHONE_5 = UIScreen.main.bounds.height == 568
let IS_IPHONE_6_7_8 = UIScreen.main.bounds.height == 667
let IS_IPHONE_X = UIScreen.main.bounds.height == 812
let IS_IPHONE_6P_7P_8P = UIScreen.main.bounds.height == 736

let kChatPresenceTimeInterval:TimeInterval = 45
let kDialogsPageLimit:UInt = 100
let kMessageContainerWidthPadding:CGFloat = 40.0

typealias FetchProfileResponse = (Bool) -> Void

let appDelegateInstance = UIApplication.shared.delegate as! AppDelegate

//let sideMenuViewController = appDelegateInstance.window?.rootViewController as! LGSideMenuController

let kPasswordMinimumLength = 6
let kPasswordMaximumLength = 15
let kUserFullNameMaximumLength = 56
let kPhoneNumberMaximumLength = 10
let kMessageMinimumLength = 25
let kMessageMaximumLength = 250
let deviceType = "iPhone"
let deviceID = UIDevice.current.identifierForVendor?.uuidString
let selectionColor = UIColor(red: 36/255.0, green: 98/255.0, blue: 126/255.0, alpha: 1.0)

let kLostInternetConnectivityAlertString = "Your internet connection seems to be lost." as String
let kEmoticonInputErrorAlertString = "Emoticons aren't allowed." as String
let kPasswordLengthAlertString = NSString(format:"The Password should consist at least %d characters.",kPasswordMinimumLength) as String
let kPasswordWhiteSpaceAlertString = "The Password should not contain any whitespaces." as String
let kUnequalPasswordsAlertString = "Both Passwords do not match." as String
let kEqualPasswordsAlertString = "Old & New Password are same." as String
let kMessageTextViewPlaceholderString = "Write your experience..." as String
let kMesssageLengthAlertString = NSString(format:"The Message should consist at least %d-%d characters.",kMessageMinimumLength,kMessageMaximumLength) as String
let kUnexpectedErrorAlertString = "An unexpected error has occurred. Please try again." as String
let kTeamNameDuplicationString = "Team name already exist!" as String
let kTeamMemberCreateAlert = "Sorry, Only Manager/Coach have permission." as String


let BASE_URL = "https://chawtechsolutions.in/amistos/"
let User_PICTURE_URL = BASE_URL + "media/user/"
let TEAM_PICTURE_URL = BASE_URL + "media/team/"

let GOOGLE_API_KEY = "AIzaSyCtpPaHtMok87cwsyY1FC82bS-iaKMpods"
let FCM_SERVER_KEY = "AIzaSyC8N9Z8TQteilDIgPbhWiqFo0tmg5Mbtzs"  

struct PROJECT_URL {
    //    static let LOGIN_API = "api/auth/signin"
}

struct USER_DEFAULTS_KEYS {
    static let Login_User_Name = "userName"
    static let Login_User_Image = "userImage"  
    static let IS_LOGIN = "isLogin"
    static let FCM_Key = "fcmKey"
}

//MARK:- Logout User
func logoutUser() {
    flushUserDefaults()
    clearImageCache()
    UIApplication.shared.delegate?.window??.rootViewController = UINavigationController(rootViewController: UIStoryboard.loginViewController())
}

//MARK:- Remove User Defaults
func flushUserDefaults() {
    let domain = Bundle.main.bundleIdentifier!
    UserDefaults.standard.removePersistentDomain(forName: domain)
    UserDefaults.standard.synchronize()
    
    let tokenStr = InstanceID.instanceID().token()  
    UserDefaults.standard.setValue(tokenStr, forKey: USER_DEFAULTS_KEYS.FCM_Key)
} 

//MARK:- Alert Methods
func showLostInternetConnectivityAlert() {
    UIAlertController.showInfoAlertWithTitle("Uh Oh!", message: kLostInternetConnectivityAlertString , buttonTitle: "Okay")
}

func showNonNumericInputErrorAlert(_ fieldName : String) {
    UIAlertController.showInfoAlertWithTitle("Error", message: String(format:"The %@ can only be numeric.",fieldName), buttonTitle: "Okay")
}

func showPasswordLengthAlert() {
    UIAlertController.showInfoAlertWithTitle("Error", message: kPasswordLengthAlertString, buttonTitle: "Okay")
}

func showPasswordWhiteSpaceAlert() {
    UIAlertController.showInfoAlertWithTitle("Error", message: kPasswordWhiteSpaceAlertString, buttonTitle: "Okay")
}

func showPasswordUnEqualAlert() {
    UIAlertController.showInfoAlertWithTitle("Error", message: kUnequalPasswordsAlertString, buttonTitle: "Okay")
}

func showPasswordEqualAlert() {
    UIAlertController.showInfoAlertWithTitle("Error", message: kEqualPasswordsAlertString, buttonTitle: "Okay")
}

func showInvalidInputAlert(_ fieldName : String) {
    UIAlertController.showInfoAlertWithTitle("Error", message: String(format:"Please enter a valid %@.",fieldName), buttonTitle: "Okay")
}

func showMessageLengthAlert() {
    UIAlertController.showInfoAlertWithTitle("Error", message: kMesssageLengthAlertString , buttonTitle: "Okay")
}
//MARK:- set tab bar item background color
extension UIImage {
    func makeImageWithColorAndSize(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0 , width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
//MARK:- MBProgressHUD Methods

func showProgressOnView(_ view:UIView) {
    let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
    loadingNotification.mode = MBProgressHUDMode.indeterminate
    loadingNotification.label.text = "Loading.."
}

func hideProgressOnView(_ view:UIView) {
    MBProgressHUD.hide(for: view, animated: true)
}

func hideAllProgressOnView(_ view:UIView) {
    MBProgressHUD.hideAllHUDs(for: view, animated: true)
}
//MARK:- Clear SDWebImage Cache

func clearImageCache() {
    SDImageCache.shared().clearDisk()
    SDImageCache.shared().clearMemory()
}

//MARK:-document directory realted method
public func getDirectoryPath() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

public func saveImageDocumentDirectory(usedImage:UIImage) {
    let fileManager = FileManager.default
    let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("temp.jpg")
    let imageData = UIImageJPEGRepresentation(usedImage, 0.5)
    fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
}
