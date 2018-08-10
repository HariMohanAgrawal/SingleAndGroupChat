//  MIT License

//  Copyright (c) 2017 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import Foundation
import UIKit
import Firebase

class User: NSObject {
    //MARK: Properties
    let name: String
    let email: String
    let id: String
    var profilePic: URL
    var token: String
    
    //MARK: Methods
    class func registerUser(withName: String, email: String, password: String, profilePic: UIImage, token: String, completion: @escaping (Bool) -> Swift.Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                user?.user.sendEmailVerification(completion: nil)
                let storageItem = Storage.storage().reference().child("usersProfilePics").child((user?.user.uid)!)
                let imageData = UIImageJPEGRepresentation(profilePic, 0.1)
                var path = ""
                storageItem.putData(imageData!, metadata: nil, completion: { (metadata, err) in
                    if err == nil {
                        storageItem.downloadURL(completion: { (url, error) in
                            if error != nil {
                                print(error!)
                                return
                            }
                            if url != nil {
                                path = (url?.absoluteString)!
                                let values = ["name": withName, "email": email, "profilePicLink": path, "token": token];   Database.database().reference().child("users").child((user?.user.uid)!).child("credentials").updateChildValues(values, withCompletionBlock: { (errr, _) in
                                    if errr == nil {
                                        let userInfo = ["email" : email, "password" : password]
                                        UserDefaults.standard.set(userInfo, forKey: "userInformation")
                                        completion(true)
                                    }
                                })
                            }
                        })
                    }
                })
            }
            else {
                completion(false)
            }
        })
    }
    
    class func updateUser(Name: String, email:String, profilePic: UIImage, token:String, completion: @escaping (Bool) -> Swift.Void) {
        let userRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("credentials")
        let storageItem = Storage.storage().reference().child("usersProfilePics").child((Auth.auth().currentUser!.uid))
        let imageData = UIImageJPEGRepresentation(profilePic, 0.1)
        var path = ""
        storageItem.putData(imageData!, metadata: nil, completion: { (metadata, err) in
            if err == nil {
                storageItem.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    if url != nil {
                        path = (url?.absoluteString)!
                        userRef.updateChildValues(["name": Name, "email": email, "profilePicLink": path, "token": token], withCompletionBlock: {(errNM, referenceNM)   in
                            if errNM == nil{
                                completion(true)
                                
                            }else{
                                completion(false)
                            }
                        })
                    }
                })
            }
        })
    }
    
    class func updateUserToken(tokenStr: String, completion: @escaping (Bool) -> Swift.Void) {
        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("credentials").updateChildValues(["token":tokenStr])
        completion(true)  
    }
    
    class func loginUser(withEmail: String, password: String, completion: @escaping (Bool, String) -> Swift.Void) {
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: { (user, error) in
            if error == nil {
                let userInfo = ["email": withEmail, "password": password]
                UserDefaults.standard.set(userInfo, forKey: "userInformation")
                completion(true,"")
            } else {
                completion(false,(error?.localizedDescription)!)
            }
        })
    }
    
    class func logOutUser(completion: @escaping (Bool) -> Swift.Void) {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "userInformation")
            completion(true)
        } catch _ {
            completion(false)
        }
    }
    
    class func forgotPassword(emailStr:String, completion: @escaping (Bool,String) -> Swift.Void) {
        Auth.auth().sendPasswordReset(withEmail: emailStr, completion: { (error) in
            if error == nil{
                completion(true,"")
            }else {
                completion(false,(error?.localizedDescription)!)
            }
        })
    }  
    
    class func getUserinfo(forUserID: String, completion: @escaping (User) -> Swift.Void) {
        Database.database().reference().child("users").child(forUserID).child("credentials").observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: String] {
                let name = data["name"]!
                let email = data["email"]!
                let profilePicUrl = URL.init(string: data["profilePicLink"]!)
                let token = data["token"]!
                let user = User.init(name: name, email: email, id: forUserID, profilePic: profilePicUrl!, token: token)
                completion(user)
            }
        })
    }
    
    class func downloadAllUsers(completion: @escaping (User) -> Swift.Void) {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            let id = snapshot.key
            let data = snapshot.value as! [String: Any]
            let credentials = data["credentials"] as! [String: String]
            let name = credentials["name"]!
            let email = credentials["email"]!
            let token = credentials["token"]!
            let profilePicUrl = URL.init(string: credentials["profilePicLink"]!)
            let user = User.init(name: name, email: email, id: id, profilePic: profilePicUrl!, token: token)
            completion(user)
        })
    }  
    
    class func checkUserVerification(completion: @escaping (Bool) -> Swift.Void) {
        Auth.auth().currentUser?.reload(completion: { (_) in
            let status = (Auth.auth().currentUser?.isEmailVerified)!
            completion(status)
        })
    }
    
    
    //MARK: Inits
    init(name: String, email: String, id: String, profilePic: URL, token: String) {
        self.name = name
        self.email = email
        self.id = id
        self.profilePic = profilePic
        self.token = token
    }
}

