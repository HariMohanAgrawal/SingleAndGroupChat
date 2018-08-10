//
//  FireBaseHandler.swift
//  GroupChat
//
//  Created by Soham Bhattacharjee on 28/12/16.

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseStorage

class Group: NSObject {
    var groupID: String?
    var groupName: String?
    var groupImage: URL?
    var grpMembers: [String : String]
    required init(id: String, grpName: String, grpImage: URL, members:[String : String]) {
        groupID = id
        groupName = grpName
        groupImage = grpImage  
        grpMembers = members
    }
    
    // MARK: Load Groups
    class func loadGroups(completionHandler: @escaping (Group) -> Swift.Void) {
        Database.database().reference().child("groups").observe(.childAdded, with: { (snapshot) in
            let groupID = snapshot.key
            let data = snapshot.value as! [String: Any]
            let credentials = data["credentials"] as! [String: String]
            let grpName = credentials["groupName"]
            var members : [String : String] = [:]
            if let memberList = data["members"] {
                members = memberList as! [String : String]
            }
            let groupPicUrl = URL.init(string: credentials["groupImage"]!)
            
            for dict in members {
                if dict.key == Auth.auth().currentUser?.uid && dict.value == "true" {
                    let grpModel = Group(id: groupID, grpName: grpName!, grpImage: groupPicUrl!, members: members)
                    completionHandler(grpModel)
                    break
                }    
            }  
        })
    }
    
    // MARK: Add Group
    class func addGroup(membersIDList:[String], groupName: String, password: String, groupImage:UIImage, completionHandler: @escaping(_ groupID: String?, _ error: Error?) -> Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            let imageData = UIImageJPEGRepresentation(groupImage, 0.1)
            var path = ""
            let storageItem = Storage.storage().reference().child("usersGroupPics").child(groupName)
            storageItem.putData(imageData!, metadata: nil, completion: { (metadata, err) in
                if err == nil {
                    storageItem.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error!)
                            return
                        } 
                        if url != nil {
                            path = (url?.absoluteString)!
                            let parameters = ["groupName": groupName,"password":password,"groupImage":path] as [String : Any]
                            Database.database().reference().child("groups").childByAutoId().child("credentials").setValue(parameters) { (error, reference) in
                                let groupdata = [reference.parent!.key : "true"]
                                let memberdata = [currentUserID : "true"]
                                Database.database().reference().child("users").child(currentUserID).child("myGroup").updateChildValues(groupdata)
                                Database.database().reference().child("groups").child(reference.parent!.key).child("members").updateChildValues(memberdata)
                                for i in 0..<membersIDList.count {
                                    Database.database().reference().child("users").child(membersIDList[i]).child("myGroup").updateChildValues([reference.parent!.key:"true"])  
                                    Database.database().reference().child("groups").child(reference.parent!.key).child("members").updateChildValues([membersIDList[i]:"true"])
                                }
                                if error == nil {
                                    completionHandler(reference.key, error)
                                }  
                            }
                        }
                    })
                }
            })
        }
    }
    
    // MARK: Update Group
    class func updateGroup(membersIDList:[String], groupId:String, groupName: String, password: String, groupImage:UIImage, completion: @escaping (Bool) -> Swift.Void) {
        if (Auth.auth().currentUser?.uid) != nil {
            let imageData = UIImageJPEGRepresentation(groupImage, 0.1)
            var path = ""
            let storageItem = Storage.storage().reference().child("usersGroupPics").child(groupName)
            let userRef = Database.database().reference().child("groups").child(groupId).child("credentials")
            storageItem.putData(imageData!, metadata: nil, completion: { (metadata, err) in
                if err == nil {
                    storageItem.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        if url != nil {
                            path = (url?.absoluteString)!
                            userRef.updateChildValues(["groupName": groupName,"password":password,"groupImage":path], withCompletionBlock: {(errNM, referenceNM)   in
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
    }
    
    // MARK: Update Group
    class func deleteMemberInGroup(membersID:String, groupId:String, completion: @escaping (Bool) -> Swift.Void) {
        if (Auth.auth().currentUser?.uid) != nil {
            Database.database().reference().child("groups").child(groupId).child("members").updateChildValues([membersID:"false"])
            Database.database().reference().child("users").child(membersID).child("myGroup").updateChildValues([groupId:"false"])
            completion(true)
        }
    }
    
    // MARK: Update Group
    class func addMemberInGroup(membersID:String, groupId:String, completion: @escaping (Bool) -> Swift.Void) {
        if (Auth.auth().currentUser?.uid) != nil {
            Database.database().reference().child("groups").child(groupId).child("members").updateChildValues([membersID:"true"])
            Database.database().reference().child("users").child(membersID).child("myGroup").updateChildValues([groupId:"true"])
            completion(true)
        }
    }
    
    // MARK: Checking for existing Group Name
    class func checkGroupNameAlreadyExists(GroupName: String, completionHandler: @escaping (_ nameExists: Bool) -> Void) {
        Database.database().reference().child("groups").observeSingleEvent(of: .value, with: { snapshot in
            print(snapshot.debugDescription)
            let postDictArray = snapshot.value as? [String : AnyObject] ?? [:]
            if postDictArray.count < 1 {
                // This is for the first time
                // No groups have been added
                completionHandler(false)
            }
            else {
                var found = false
                for dict in postDictArray {
                    let innerDict = dict.value as? [String : AnyObject]
                    let groupCredentialDict = innerDict!["credentials"] as? NSDictionary
                    if (groupCredentialDict!["groupName"] as AnyObject).localizedLowercase == GroupName.localizedLowercase {
                        found = true
                        break
                    }
                }
                completionHandler(found)
            }
            
        }) { error in
            completionHandler(false)
        }
    }
    
    
    // MARK: Token Refresh
    //    class func tokenRefresh(user: User, completionHandler: @escaping (_ error: Error?) -> Void) {
    //        user.getTokenForcingRefresh(true) { (idToken, error) in
    //            completionHandler(error)
    //        }
    //    }
    
    // MARK: Online/Offline capabilities
    //    class func getUserStatusNetworkStatus(completionHandler: @escaping (_ loggedInUser: User?) -> Void) {
    //
    //        Auth.auth().addStateDidChangeListener() { (auth, user) in
    //            if let user = user {
    //                print("User is signed in with uid:", user.uid)
    //                completionHandler(user)
    //            } else {
    //                print("No user is signed in.")
    //                completionHandler(nil)
    //            }
    //        }
    //    }
    
    //    // MARK: - Create, Delete, Modify Chat
    
    //    class func resendVerificationMail(_ user: User, completionHandler: @escaping (_ error: Error?) -> Void) {
    //        user.sendEmailVerification(completion: { (error) in
    //            completionHandler(error)
    //        })
    //    }
   
    //    // MARK: Handle User Photo
    //    class func uploadUserPhoto(userImage image: UIImage, storageRefrence storageRef: StorageReference, databaseReference databaseRef: DatabaseReference, firebaseUser user: User, completionHandler: @escaping (_ hasUploaded: Bool, _ photoURL: URL?) -> Void) {
    //        var data = NSData()
    //        data = UIImageJPEGRepresentation(image, 0.8)! as NSData
    //
    //        // set upload path
    //        let filePath = "\(user.uid)/\("userPhoto")"
    //        let metaData = StorageMetadata()
    //        metaData.contentType = "image/jpg"
    //
    //        storageRef.child(filePath).put(data as Data, metadata: metaData){ (metaData, error) in
    //            if let error = error {
    //                print(error.localizedDescription)
    //                completionHandler(false, nil)
    //                return
    //            } else {
    //                //store downloadURL
    //                let downloadURL = metaData!.downloadURL()!.absoluteString
    //                //store downloadURL at database
    //                databaseRef.child("users").child(user.uid).updateChildValues(["userPhoto": downloadURL])
    //                completionHandler(true, URL(fileURLWithPath: downloadURL))
    //            }
    //        }
    //    }
    //    class func deleteUserPhoto(storageRefrence storageRef: StorageReference, completionHandler: @escaping (_ hasDeleted: Bool, _ error: Error?) -> Void) {
    //        // Create a reference to the file to delete
    //        let desertRef = storageRef.child("userPhoto")
    //
    //        // Delete the file
    //        desertRef.delete { error in
    //            if let error = error {
    //                // Uh-oh, an error occurred!
    //                completionHandler(false, error)
    //            } else {
    //                // File deleted successfully
    //                completionHandler(true, error)
    //            }
    //        }
    //    }
}
