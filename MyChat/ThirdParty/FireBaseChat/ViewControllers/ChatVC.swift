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


import UIKit
import Photos
import Firebase
import CoreLocation

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {
    
    //MARK: Properties
    @IBOutlet var inputBar: UIView!  
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var CustomNavigationBar: CustomNavigationBar!
    override var inputAccessoryView: UIView? {
        get {
            self.inputBar.frame.size.height = self.barHeight
            self.inputBar.clipsToBounds = true
            return self.inputBar
        }
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    let locationManager = CLLocationManager()
    var items = [Message]()
    let imagePicker = UIImagePickerController()
    let barHeight: CGFloat = 50
    var currentUser: User?
    var currentUserName: String = ""
    var canSendLocation = true
    var currentGroup: Group?
    var chatUserName: String = ""

    //MARK: Methods
    func customization() {
        self.imagePicker.delegate = self
        self.tableView.estimatedRowHeight = self.barHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.contentInset.bottom = self.barHeight
        self.tableView.scrollIndicatorInsets.bottom = self.barHeight
        self.title = self.currentUserName
        locationManager.delegate = self
        //.....................New Code.....................
        self.navigationController?.isNavigationBarHidden = true
        
        if currentGroup != nil {
            CustomNavigationBar.titleLabel.text = currentGroup?.groupName
            CustomNavigationBar.imgView.sd_setImage(with: currentGroup?.groupImage, placeholderImage: #imageLiteral(resourceName: "placeholder"))
            var memberNameStr = ""
            
            for member in (currentGroup?.grpMembers)! {
                if member.value == "true" {
                    memberNameStr = memberNameStr + (Global.items.first(where: {$0.id == member.key})?.name)! + ", "
                }
            } 
            let result = String(memberNameStr.dropLast(2))
            CustomNavigationBar.subTitleLabel.text = result
        }
        else {
            CustomNavigationBar.titleLabel.text = currentUserName
            CustomNavigationBar.imgView.sd_setImage(with: currentUser?.profilePic, placeholderImage: #imageLiteral(resourceName: "placeholder"))
            CustomNavigationBar.subTitleLabel.text = ""
        }
    }  
    
    //Downloads messages
    func fetchData() {
        if currentGroup != nil {
            Message.downloadGroupAllMessages(groupId: (currentGroup?.groupID)!, completion: {[weak weakSelf = self] (message) in
                weakSelf?.items.append(message)
                weakSelf?.items.sort{ $0.timestamp < $1.timestamp }
                DispatchQueue.main.async {
                    if let state = weakSelf?.items.isEmpty, state == false {
                        weakSelf?.tableView.reloadData()
                        weakSelf?.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
                    }
                }
            })  
        }
        else {
            Message.downloadAllMessages(forUserID: self.currentUser!.id, completion: {[weak weakSelf = self] (message) in
                weakSelf?.items.append(message)
                weakSelf?.items.sort{ $0.timestamp < $1.timestamp }
                DispatchQueue.main.async {
                    if let state = weakSelf?.items.isEmpty, state == false {
                        weakSelf?.tableView.reloadData()
                        weakSelf?.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
                    }
                }
            })
            Message.markMessagesRead(forUserID: self.currentUser!.id)
        }  
    }
    
    func composeMessage(type: MessageType, content: Any)  {
        let message = Message.init(type: type, senderName: currentUserName, content: content, owner: .sender, timestamp: Int(Date().timeIntervalSince1970), isRead: false)
        if currentGroup != nil {
            //For Group Chat
            Message.createChat(senderName: UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.Login_User_Name) as! String, message: message, mediaName: "", group: currentGroup!, toToken: "", completion: {(_) in
            })
        }
        else {
            //For individual Chat
            Message.send(message: message, senderName: self.currentUserName, toID: self.currentUser!.id, toToken: self.currentUser!.token, completion: {(_) in
            })
        }
    }
    
    func checkLocationPermission() -> Bool {
        var state = false
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            state = true
        case .authorizedAlways:
            state = true
        default: break
        }
        return state
    }
    
    func animateExtraButtons(toHide: Bool)  {
        switch toHide {
        case true:
            self.bottomConstraint.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.inputBar.layoutIfNeeded()
            }  
        default:
            self.bottomConstraint.constant = -50
            UIView.animate(withDuration: 0.3) {
                self.inputBar.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func showMessage(_ sender: Any) {
       self.animateExtraButtons(toHide: true)
    }
    
    @IBAction func selectGallery(_ sender: Any) {
        self.animateExtraButtons(toHide: true)
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .authorized || status == .notDetermined) {
            self.imagePicker.sourceType = .savedPhotosAlbum;
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func selectCamera(_ sender: Any) {
        self.animateExtraButtons(toHide: true)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if (status == .authorized || status == .notDetermined) {
                self.imagePicker.sourceType = .camera
                self.imagePicker.allowsEditing = false
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        else {
            UIAlertController.showInfoAlertWithTitle("Alert!", message: "Sorry! Camera is not available.", buttonTitle: "Okay")  
        }
    }
    
    @IBAction func selectLocation(_ sender: Any) {
        self.canSendLocation = true
        self.animateExtraButtons(toHide: true)
        if self.checkLocationPermission() {
            self.locationManager.startUpdatingLocation()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func showOptions(_ sender: Any) {
        self.animateExtraButtons(toHide: false)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if let text = self.inputTextField.text {
            if text.characters.count > 0 {
                self.composeMessage(type: .text, content: self.inputTextField.text!)
                self.inputTextField.text = ""
            }
        }
    }
    
    //MARK: NotificationCenter handlers
    @objc func showKeyboard(notification: Notification) {
        if let frame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let height = frame.cgRectValue.height
            self.tableView.contentInset.bottom = height
            self.tableView.scrollIndicatorInsets.bottom = height
            if self.items.count > 0 {
                self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }

    //MARK: Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.items[indexPath.row].owner {
        case .receiver:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Receiver", for: indexPath) as! ReceiverCell
            cell.clearCellData()
            switch self.items[indexPath.row].type {
            case .text:
                cell.message.text = self.items[indexPath.row].content as! String
                cell.timeLbl.text = self.getDateTimeFromTimeStamp(timeStamp: Double(self.items[indexPath.row].timestamp))
            case .photo:
                if let image = self.items[indexPath.row].image {
                    cell.messageBackground.image = image  
                    cell.message.isHidden = true
                    cell.timeLbl.text = self.getDateTimeFromTimeStamp(timeStamp: Double(self.items[indexPath.row].timestamp))
                } else {
                    cell.messageBackground.image = UIImage.init(named: "loading")
                    cell.timeLbl.text = self.getDateTimeFromTimeStamp(timeStamp: Double(self.items[indexPath.row].timestamp))
                    self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
                        if state == true {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            case .location:
                cell.messageBackground.image = UIImage.init(named: "location")
                cell.message.isHidden = true
            }
            return cell
        case .sender:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Sender", for: indexPath) as! SenderCell
            cell.clearCellData()
//            cell.profilePic.image = self.currentUser?.profilePic
            switch self.items[indexPath.row].type {
            case .text:
                cell.message.text = self.items[indexPath.row].content as! String
                cell.nameLbl.text = self.items[indexPath.row].senderName
                cell.timeLbl.text = self.getDateTimeFromTimeStamp(timeStamp: Double(self.items[indexPath.row].timestamp))
            case .photo:
                if let image = self.items[indexPath.row].image {
                    cell.nameLbl.text = self.items[indexPath.row].senderName
                    cell.messageBackground.image = image
                    cell.message.isHidden = true
                    cell.timeLbl.text = self.getDateTimeFromTimeStamp(timeStamp: Double(self.items[indexPath.row].timestamp))
                } else {
                    cell.nameLbl.text = self.items[indexPath.row].senderName
                    cell.messageBackground.image = UIImage.init(named: "loading")
                    cell.timeLbl.text = self.getDateTimeFromTimeStamp(timeStamp: Double(self.items[indexPath.row].timestamp))
                    self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
                        if state == true {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }    
                    })
                }
            case .location: 
                cell.nameLbl.text = self.items[indexPath.row].senderName
                cell.messageBackground.image = UIImage.init(named: "location")
                cell.message.isHidden = true
            }
            return cell
        }
    }  
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.inputTextField.resignFirstResponder()
        switch self.items[indexPath.row].type {
        case .photo:
            if let photo = self.items[indexPath.row].image {
                let info = ["viewType" : ShowExtraView.preview, "pic": photo] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showExtraView"), object: nil, userInfo: info)
                self.inputAccessoryView?.isHidden = true
            }
        case .location:
            let coordinates = (self.items[indexPath.row].content as! String).components(separatedBy: ":")
            let location = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(coordinates[0])!, longitude: CLLocationDegrees(coordinates[1])!)
            let info = ["viewType" : ShowExtraView.map, "location": location] as [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showExtraView"), object: nil, userInfo: info)
            self.inputAccessoryView?.isHidden = true
        default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.composeMessage(type: .photo, content: pickedImage)
        } else {
            let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.composeMessage(type: .photo, content: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        if let lastLocation = locations.last {
            if self.canSendLocation {
                let coordinate = String(lastLocation.coordinate.latitude) + ":" + String(lastLocation.coordinate.longitude)
                let message = Message.init(type: .location, senderName: currentUserName, content: coordinate, owner: .sender, timestamp: Int(Date().timeIntervalSince1970), isRead: false)
                if currentGroup != nil {
                    Message.createChat(senderName: UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.Login_User_Name) as! String, message: message, mediaName: "", group: currentGroup!, toToken: "", completion: {(_) in
                    })
                }
                else {
                    Message.send(message: message,senderName:currentUserName, toID: self.currentUser!.id, toToken: self.currentUser!.token, completion: {(_) in
                    })
                }
                self.canSendLocation = false
            }
        }
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: ViewController lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.inputBar.backgroundColor = UIColor.white
        self.view.layoutIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.showKeyboard(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
         NotificationCenter.default.removeObserver(self)
        if currentUser != nil {
            Message.markMessagesRead(forUserID: self.currentUser!.id)
        }
        else {
            Message.markGroupMessagesRead(forGroupId: (self.currentGroup?.groupID)!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
        self.fetchData()
        appDelegateInstance.handleNotifications()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        CustomNavigationBar.imgView.isUserInteractionEnabled = true
        CustomNavigationBar.imgView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        if currentGroup  != nil {
            let viewController = UIStoryboard.UpdateGroupViewController()
            viewController.selectedGroup = currentGroup
            self.navigationController?.pushViewController(viewController, animated: true)  
        }
    }
}

extension UIViewController {
    func hideNavigationBar(){
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    func showNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}
