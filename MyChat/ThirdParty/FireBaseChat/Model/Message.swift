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

class Message {
    
    //MARK: Properties
    var owner: MessageOwner
    var type: MessageType
    var content: Any
    var timestamp: Int
    var isRead: Bool
    var senderName: String?
    var image: UIImage?
    private var toID: String?
    private var fromID: String?
    
    //MARK: Methods
    class func downloadAllMessages(forUserID: String, completion: @escaping (Message) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(currentUserID).child("conversations").child(forUserID).observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    Database.database().reference().child("conversations").child(location).observe(.childAdded, with: { (snap) in
                        if snap.exists() {
                            let receivedMessage = snap.value as! [String: Any]
                            let messageType = receivedMessage["type"] as! String
                            var type = MessageType.text
                            switch messageType {
                            case "photo":
                                type = .photo
                            case "location":
                                type = .location
                            default: break
                            }
                            let content = receivedMessage["content"] as! String
                            let fromID = receivedMessage["fromID"] as! String
                            let timestamp = receivedMessage["timestamp"] as! Int
                            let senderName = receivedMessage["senderName"] as! String
                            if fromID == currentUserID {
                                let message = Message.init(type: type, senderName: senderName, content: content, owner: .receiver, timestamp: timestamp, isRead: true)
                                completion(message)
                            } else {
                                let message = Message.init(type: type, senderName: senderName, content: content, owner: .sender, timestamp: timestamp, isRead: true)
                                completion(message)
                            }
                        }
                    })
                }
            })
        }
    }
    
    //MARK: Methods
    class func downloadGroupAllMessages(groupId: String, completion: @escaping (Message) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("groups").child(groupId).child("conversations").observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    Database.database().reference().child("conversations").child(location).observe(.childAdded, with: { (snap) in
                        if snap.exists() {
                            let data = snap.value as! [String: Any]
                            if let receivedMessage : [String: Any] = data["message"] as? [String: Any] {
                                let messageType = receivedMessage["type"] as! String
                                var type = MessageType.text
                                switch messageType {
                                case "photo":
                                    type = .photo
                                case "location":
                                    type = .location
                                default: break
                                }
                                let content = receivedMessage["content"] as! String
                                let fromID = receivedMessage["fromID"] as! String
                                let timestamp = receivedMessage["timestamp"] as! Int
                                let senderName = receivedMessage["senderName"] as! String
                                if fromID == currentUserID {
                                    let message = Message.init(type: type, senderName: senderName, content: content, owner: .receiver, timestamp: timestamp, isRead: true)
                                    completion(message)
                                }
                                else {
                                    let message = Message.init(type: type, senderName: senderName, content: content, owner: .sender, timestamp: timestamp, isRead: true)
                                    completion(message)
                                }
                            }
                        }
                    })
                }
            })
        }
    }    
    
    func downloadImage(indexpathRow: Int, completion: @escaping (Bool, Int) -> Swift.Void)  {
        if self.type == .photo {
            let imageLink = self.content as! String
            let imageURL = URL.init(string: imageLink)
            URLSession.shared.dataTask(with: imageURL!, completionHandler: { (data, response, error) in
                if error == nil {
                    self.image = UIImage.init(data: data!)
                    completion(true, indexpathRow)
                }
            }).resume()
        }
    }
    
    class func markMessagesRead(forUserID: String)  {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(currentUserID).child("conversations").child(forUserID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    Database.database().reference().child("conversations").child(location).observeSingleEvent(of: .value, with: { (snap) in
                        if snap.exists() {
                            for item in snap.children {
                                let receivedMessage = (item as! DataSnapshot).value as! [String: Any]
                                let fromID = receivedMessage["fromID"] as! String
                                if fromID != currentUserID {
                                    Database.database().reference().child("conversations").child(location).child((item as! DataSnapshot).key).child("isRead").setValue(true)
                                }
                            }
                        }
                    })
                }
            })
        }
    }
    
    class func getMessagesUnread(forUserID: String, completion: @escaping (Bool,Int) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(currentUserID).child("conversations").child(forUserID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    Database.database().reference().child("conversations").child(location).observeSingleEvent(of: .value, with: { (snap) in
                        if snap.exists() {
                            var count = 0
                            for item in snap.children {
                                let receivedMessage = (item as! DataSnapshot).value as! [String: Any]
                                let fromID = receivedMessage["fromID"] as! String
                                let status = receivedMessage["isRead"] as! Bool
                                if fromID != forUserID && status == false {
                                   count = count + 1
                                }
                            }
                            completion(true,count)
                        }
                        else {
                            completion(false,0)
                        }
                    })
                }
            })
        }
    }
    
    func downloadLastMessage(forLocation: String, completion: @escaping () -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("conversations").child(forLocation).observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    for snap in snapshot.children {
                        let receivedMessage = (snap as! DataSnapshot).value as! [String: Any]
                        self.content = receivedMessage["content"]!
                        self.timestamp = receivedMessage["timestamp"] as! Int
                        let messageType = receivedMessage["type"] as! String
                        let fromID = receivedMessage["fromID"] as! String
                        self.isRead = receivedMessage["isRead"] as! Bool
                        var type = MessageType.text
                        switch messageType {
                        case "text":
                            type = .text
                        case "photo":
                            type = .photo
                        case "location":
                            type = .location
                        default: break
                        }
                        self.type = type
                        if currentUserID == fromID {
                            self.owner = .receiver
                        } else {
                            self.owner = .sender
                        }
                        completion()
                    }
                }
            })
        }
    }
    
    class func send(message: Message, senderName: String, toID: String, toToken: String, completion: @escaping (Bool) -> Swift.Void)  {
        if let currentUserID = Auth.auth().currentUser?.uid {  
            switch message.type {
            case .location:
                let values = ["type": "location", "senderName": senderName, "content": message.content, "fromID": currentUserID, "toID": toID, "timestamp": message.timestamp, "isRead": false]
                Message.uploadMessage(withValues: values, toID: toID, toToken: toToken, completion: { (status) in
                    completion(status)
                })
            case .photo:
                let imageData = UIImageJPEGRepresentation((message.content as! UIImage), 0.5)
                let child = UUID().uuidString
                var path = ""
                let storageItem = Storage.storage().reference().child("messagePics").child(child)
                storageItem.putData(imageData!, metadata: nil, completion: { (metadata, error) in
                    if error == nil {
                        storageItem.downloadURL(completion: { (url, error) in
                            if error != nil {
                                print(error!)  
                                return
                            }
                            if url != nil {
                                path = (url?.absoluteString)!
                                let values = ["type": "photo", "senderName": senderName, "content": path, "fromID": currentUserID, "toID": toID, "timestamp": message.timestamp, "isRead": false] as [String : Any]
                                Message.uploadMessage(withValues: values, toID: toID, toToken: toToken, completion: { (status) in
                                    completion(status)
                                })
                            }
                        })
                    }
                })  
            case .text:
                let values = ["type": "text","senderName": senderName, "content": message.content, "fromID": currentUserID, "toID": toID, "timestamp": message.timestamp, "isRead": false]
                Message.uploadMessage(withValues: values, toID: toID, toToken: toToken, completion: { (status) in
                    completion(status)
                })
            }  
        }
    }
    
    class func uploadMessage(withValues: [String: Any], toID: String, toToken: String, completion: @escaping (Bool) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(currentUserID).child("conversations").child(toID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    Database.database().reference().child("conversations").child(location).childByAutoId().setValue(withValues, withCompletionBlock: { (error, _) in
                        if error == nil {
                            self.SendSinglePush(imageUrlStr: withValues["content"] as! String, toID: toID, message: "Your have chat notification from \"" + "\(String(describing: withValues["senderName"]!))" + "\"" , token: toToken)
                            completion(true)
                        } else {
                            completion(false)
                        }
                    })
                } else {
                    Database.database().reference().child("conversations").childByAutoId().childByAutoId().setValue(withValues, withCompletionBlock: { (error, reference) in
                        let data = ["location": reference.parent!.key]
                        Database.database().reference().child("users").child(currentUserID).child("conversations").child(toID).updateChildValues(data)
                        Database.database().reference().child("users").child(toID).child("conversations").child(currentUserID).updateChildValues(data)
                        self.SendSinglePush(imageUrlStr: withValues["content"] as! String, toID: toID, message: "Your have chat notification from \"" + "\(String(describing: withValues["senderName"]!))" + "\"" , token: toToken)
                        completion(true)
                    })
                }
            })
        }   
    }
  
    class func SendSinglePush(imageUrlStr:String, toID: String, message: String, token: String) {
        self.getMessagesUnread(forUserID: toID) { (status,count) in
            var request = URLRequest(url: URL(string: "https://fcm.googleapis.com/fcm/send")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("key=" + FCM_SERVER_KEY , forHTTPHeaderField: "Authorization")
            let json = [
                "to" :token,
                "priority" : "high",
                "content_available": true,
                "mutable_content": true,
                "notification" : [
                    "body" : message,
                    "sound" : "default",
                    "badge" : count
                ],
                "data" : [
                    "imageUrlString" : imageUrlStr
                ],
                ] as [String : Any]  
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                request.httpBody = jsonData
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Error=\(String(describing: error))")
                        return
                    }
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        // check for http errors
                        print("Status Code should be 200, but is \(httpStatus.statusCode)")
                        print("Response = \(String(describing: response))")
                    }
                    
                    let responseString = String(data: data, encoding: .utf8)
                    print("responseString = \(String(describing: responseString))")
                }
                task.resume()
            }
            catch {
                print(error)
            }
        }
    }
    
    class func markGroupMessagesRead(forGroupId: String)  {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("groups").child(forGroupId).child("conversations").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    Database.database().reference().child("conversations").child(location).observeSingleEvent(of: .value, with: { (snap) in
                        if snap.exists() {
                            for item in snap.children {
                                let data = (item as! DataSnapshot).value as! [String: Any]
                                var members : [String : Bool] = [:]
                                if let memberList = data["memberReadStatus"] {
                                    members = memberList as! [String : Bool]
                                }
                                for dict in members {
                                    if dict.key == currentUserID && dict.value == false {
                                        Database.database().reference().child("conversations").child(location).child((item as! DataSnapshot).key).child("memberReadStatus").child(currentUserID).setValue(true)  
                                        break
                                    }
                                }
                            }
                        }
                    })
                }
            })
        }
    }
    
    class func getGroupMessagesUnread(groupId: String, forUserID: String, completion: @escaping (Bool,Int) -> Swift.Void) {
        if (Auth.auth().currentUser?.uid) != nil {
            Database.database().reference().child("groups").child(groupId).child("conversations").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    Database.database().reference().child("conversations").child(location).observeSingleEvent(of: .value, with: { (snap) in
                        if snap.exists() {
                            var count = 0
                            for item in snap.children {
                                let data = (item as! DataSnapshot).value as! [String: Any]
                                var members : [String : Bool] = [:]
                                if let memberList = data["memberReadStatus"] {
                                    members = memberList as! [String : Bool]
                                }
                                for dict in members {
                                    if dict.key == forUserID && dict.value == false {
                                        count = count + 1
                                        break
                                    }
                                }
                            }
                            completion(true,count)
                        }
                        else {
                            completion(false,0)
                        }  
                    })
                }
            })
        }
    }
    
    class func createChat(senderName: String, message: Message, mediaName: String?, group: Group, toToken:String, completion: @escaping (Bool) -> Swift.Void)  {
        if let currentUserID = Auth.auth().currentUser?.uid {
            switch message.type {
            case .location:
                let values = ["type": "location", "senderName": senderName, "content": message.content, "fromID": currentUserID, "toID": group.groupID!, "timestamp": message.timestamp, "isRead": false]
                Message.uploadGroupMessage(withValues: values, toGroup: group, toToken: toToken, completion: { (status) in
                    completion(status)
                })  
            case .photo:
                let imageData = UIImageJPEGRepresentation((message.content as! UIImage), 0.5)
                let child = UUID().uuidString
                var path = ""
                let storageItem = Storage.storage().reference().child("messagePics").child(child)
                storageItem.putData(imageData!, metadata: nil, completion: { (metadata, error) in
                    if error == nil {
                        storageItem.downloadURL(completion: { (url, error) in
                            if error != nil {
                                print(error!)
                                return
                            }
                            if url != nil {
                                path = (url?.absoluteString)!
                                let values = ["type": "photo", "senderName": senderName, "content": path, "fromID": currentUserID, "toID": group.groupID!, "timestamp": message.timestamp, "isRead": false] as [String : Any]
                                Message.uploadGroupMessage(withValues: values, toGroup: group, toToken: toToken, completion: { (status) in
                                    completion(status)
                                })
                            }
                        })
                    }
                })
            case .text:
                let values = ["type": "text", "senderName": senderName, "content": message.content, "fromID": currentUserID, "toID": group.groupID!, "timestamp": message.timestamp, "isRead": false]
                Message.uploadGroupMessage(withValues: values, toGroup: group, toToken: toToken, completion: { (status) in
                    completion(status)
                })
            }      
        }
    }
    
    class func uploadGroupMessage(withValues: [String: Any], toGroup: Group, toToken: String, completion: @escaping (Bool) -> Swift.Void) {
//        let staticMapUrl: String = "http://maps.google.com/maps/api/staticmap?markers=color:red|\(lastLocation.coordinate.latitude),\(lastLocation.coordinate.longitude)&\("zoom=16&size=400x400")&sensor=true"
//        let mapUrl = URL(string: staticMapUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
//        let data = try? Data(contentsOf: mapUrl!)
//        if let imageData = data {
//            let image = UIImage(data: imageData)!
//        }
        if (Auth.auth().currentUser?.uid) != nil {
            Database.database().reference().child("groups").child(toGroup.groupID!).child("conversations").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    Database.database().reference().child("conversations").child(location).childByAutoId().child("message").setValue(withValues, withCompletionBlock: { (error, reference) in
                        if error == nil {
                            for member in (toGroup.grpMembers) {
                                if member.value == "true" && member.key != Auth.auth().currentUser?.uid {
                                    let memberTokenStr = (Global.items.first(where: {$0.id == member.key})?.token)!
                                    Database.database().reference().child("conversations").child(location).child(reference.parent!.key).child("memberReadStatus").updateChildValues([member.key:false])

                                    self.SendGroupPush(imageUrlStr: withValues["content"] as! String, groupId: toGroup.groupID!, toID: member.key, message: "Your have chat notification from \"" + toGroup.groupName! + "\"" , token: memberTokenStr)
                                }
                                else {
                                    Database.database().reference().child("conversations").child(location).child(reference.parent!.key).child("memberReadStatus").updateChildValues([member.key:true])
                                }
                            }
                            completion(true)
                        }
                        else {
                            completion(false)
                        }
                    })  
                }
                else {
                    Database.database().reference().child("conversations").childByAutoId().childByAutoId().child("message").setValue(withValues, withCompletionBlock: { (error, reference) in
                        let data = ["location": reference.parent?.parent!.key]
                        Database.database().reference().child("groups").child(toGroup.groupID!).child("conversations").updateChildValues(data)
                        var endLoop = 0
                        for member in (toGroup.grpMembers) {
                            endLoop = endLoop + 1
                            if member.value == "true" && member.key != Auth.auth().currentUser?.uid {
                                let memberTokenStr = (Global.items.first(where: {$0.id == member.key})?.token)!
                                Database.database().reference().child("conversations").child((reference.parent?.parent?.key)!).child((reference.parent?.key)!).child("memberReadStatus").updateChildValues([member.key:false])
                                
                                self.SendGroupPush(imageUrlStr: withValues["content"] as! String, groupId: toGroup.groupID!, toID: member.key, message: "Your have chat notification from \"" + toGroup.groupName! + "\"" , token: memberTokenStr)
                            }
                            else {
                                Database.database().reference().child("conversations").child((reference.parent?.parent?.key)!).child((reference.parent?.key)!).child("memberReadStatus").updateChildValues([member.key:true])
                            }
                        }
                        
                        if endLoop == toGroup.groupName?.count {
                            completion(true)
                        }
                    })
                }
            })
        }
    }    
    
    class func SendGroupPush(imageUrlStr:String, groupId:String, toID: String, message: String, token: String) {
        self.getGroupMessagesUnread(groupId:groupId, forUserID: toID) { (status,count) in
        var request = URLRequest(url: URL(string: "https://fcm.googleapis.com/fcm/send")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=" + FCM_SERVER_KEY , forHTTPHeaderField: "Authorization")
        let json = [
            "to" :token,
            "priority" : "high",
            "content_available": true,
            "mutable_content": true,
            "notification" : [
                "body" : message,
                "sound" : "default",
                "badge" : count
            ],
            "data" : [
                "imageUrlString" : imageUrlStr
            ],
            ] as [String : Any] 
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error=\(String(describing: error))")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    // check for http errors
                    print("Status Code should be 200, but is \(httpStatus.statusCode)")
                    print("Response = \(String(describing: response))")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(String(describing: responseString))")
            }
            task.resume()
        }
        catch {
            print(error)
        }
        }
    }
    
    //MARK: Inits
    init(type: MessageType, senderName:String, content: Any, owner: MessageOwner, timestamp: Int, isRead: Bool) {
        self.type = type
        self.content = content
        self.owner = owner
        self.timestamp = timestamp
        self.isRead = isRead
        self.senderName = senderName
    }
}
