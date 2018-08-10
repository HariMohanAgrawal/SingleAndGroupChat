//
//  UpdateGroupViewController.swift
//  MyChat
//
//  Created by Amit on 14/07/18.
//  Copyright © 2018 Amit. All rights reserved.
//

import UIKit
import Firebase

class UpdateGroupViewController: UIViewController {
    @IBOutlet weak var CustomNavigationBar: CustomNavigationBar!
    @IBOutlet weak var GroupMemberListTableView: UITableView!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var userImageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    var selectedGroup: Group?
    var memberIdList = [String]()
    var memberList = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CustomNavigationBar.titleLabel.text = selectedGroup?.groupName
        CustomNavigationBar.imgView.isHidden = true
        CustomNavigationBar.titleLeadingConstraint.constant = 10 + 30 + 8
        userImageView.sd_setImage(with: selectedGroup?.groupImage, placeholderImage: #imageLiteral(resourceName: "placeholder"))  
        groupNameTextField.text = selectedGroup?.groupName
        GroupMemberListTableView.tableFooterView = UIView()
        imagePicker.delegate = self
        
        for member in (selectedGroup?.grpMembers)! {
            if member.value == "true" {
                self.memberIdList.append(member.key)
                let user = Global.items.first(where: {$0.id == member.key})
                self.memberList.append(user!)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cameraBtnTap(_ sender: Any) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender as? UIView
            alert.popoverPresentationController?.sourceRect = (sender as AnyObject).bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addMemberBtnTap(_ sender: Any) {
        var arr = [User]()
        for member in Global.items {
            if !self.memberList.contains(where: {$0.id == member.id}) {
                arr.append(member)
            }
        }
        let viewController = UIStoryboard.AddDeleteMemberViewController()
        viewController.memberList = arr
        viewController.selectedGroup = self.selectedGroup
        viewController.addBool = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func deleteMemberBtnTap(_ sender: Any) {
        let viewController = UIStoryboard.AddDeleteMemberViewController()
        viewController.memberList = self.memberList
        viewController.selectedGroup = self.selectedGroup
        viewController.addBool = false  
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func saveSettingBtnTap(_ sender: Any) {
//        Group.checkGroupNameAlreadyExists(GroupName: groupNameTextField.text!) { (status) in
//            hideAllProgressOnView(self.view)
//            if status == true {
//                UIAlertController.showInfoAlertWithTitle("Alert!", message: "Group Name Already Exist!", buttonTitle: "Okay")
//            }
//            else {
                showProgressOnView(self.view)
                Group.updateGroup(membersIDList: self.memberIdList, groupId: (self.selectedGroup?.groupID)!, groupName: self.groupNameTextField.text!, password: "1234", groupImage: self.userImageView.image!) { (status) in
                    if status == true {
                        let alert = UIAlertController(title: "Alert!", message: "Group has been successfully updated.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler:{ (UIAlertAction)in
                            for controller: Any? in self.navigationController?.viewControllers ?? [Any?]() {
                                if (controller is ChatUserListViewController) {
                                    if let aController = controller as? UIViewController {
                                        self.navigationController?.popToViewController(aController, animated: true)
                                    }
                                }
                            }
                        })) 
                        self.present(alert, animated: true, completion: nil)
                    }
                }
//            }
//        }
    }  
}

extension UpdateGroupViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatUserListTableViewCell") as! ChatUserListTableViewCell
        cell.MemberImageView.sd_setImage(with: memberList[indexPath.row].profilePic, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        if memberList[indexPath.row].id == Auth.auth().currentUser?.uid {  
            cell.MemberNameLbl.text = "You"
        }
        else {
            cell.MemberNameLbl.text = memberList[indexPath.row].name
        }
        cell.selectedImageView.isHidden = true
        return cell
    }
}

extension UpdateGroupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension UpdateGroupViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary() {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //            userImageView.contentMode = .scaleAspectFill
            userImageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
