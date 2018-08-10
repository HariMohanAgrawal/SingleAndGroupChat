//
//  AddGroupViewController.swift
//  MyChat
//
//  Created by Amit on 09/07/18.
//  Copyright © 2018 Amit. All rights reserved.
//

import UIKit
import Firebase

class AddGroupViewController: UIViewController {
    @IBOutlet weak var CustomNavigationBar: CustomNavigationBar!
    @IBOutlet weak var UserListTableView: UITableView!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var UserListCollectionView: UICollectionView!
    @IBOutlet weak var userListCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userImageView: UIImageView!
    let imagePicker = UIImagePickerController()

    var users = [User]()
    var SelectedUserList = [User]()
    var SelectedUserMemberID = [String]()

    var groupStore = [Group]()
    override func viewDidLoad() {
        super.viewDidLoad()
        CustomNavigationBar.titleLabel.text = "New Group"
        CustomNavigationBar.imgView.isHidden = true
        CustomNavigationBar.titleLeadingConstraint.constant = 10 + 30 + 8
        
        UserListTableView.tableFooterView = UIView()
        UserListTableView.allowsMultipleSelection = true
        userListCollectionViewHeightConstraint.constant = 0
        imagePicker.delegate = self
    }
      
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addGroupBtnTap(_ sender: Any) {
        if (groupNameTextField.text?.isEmpty)! {
            UIAlertController.showInfoAlertWithTitle("Alert!", message: "Please Enter Group Name", buttonTitle: "Okay")
        }
        else if SelectedUserMemberID.count == 0 {
            UIAlertController.showInfoAlertWithTitle("Alert!", message: "Please Selected At Least One Person", buttonTitle: "Okay")
        }
        else {
            showProgressOnView(self.view)
//            Group.checkGroupNameAlreadyExists(GroupName: groupNameTextField.text!) { (status) in
//                hideAllProgressOnView(self.view)
//                if status == true {
//                    UIAlertController.showInfoAlertWithTitle("Alert!", message: "Group Name Already Exist!", buttonTitle: "Okay")
//                }
//                else {
                    showProgressOnView(self.view)
                    Group.addGroup(membersIDList:self.SelectedUserMemberID, groupName: self.groupNameTextField.text!, password: "1234", groupImage:self.userImageView.image!) { (status, err) in
                        hideAllProgressOnView(self.view)
                        UIAlertController.showInfoAlertWithTitle("Alert!", message: "Group Has been Created Successfully!", buttonTitle: "Okay")
                        self.navigationController?.popViewController(animated: true)
//                    }
//                }
            }
        }
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
}

extension AddGroupViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatUserListTableViewCell") as! ChatUserListTableViewCell
        cell.MemberImageView.sd_setImage(with: users[indexPath.row - groupStore.count].profilePic, placeholderImage: #imageLiteral(resourceName: "placeholder"))  
        cell.MemberNameLbl.text = users[indexPath.row - groupStore.count].name
        return cell
    }
}

extension AddGroupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! ChatUserListTableViewCell
        selectedCell.selectedImageView.image = #imageLiteral(resourceName: "selected")
        SelectedUserList.append(users[indexPath.row])
        SelectedUserMemberID.append(users[indexPath.row].id)
        userListCollectionViewHeightConstraint.constant = 70
        SelectedUserList = SelectedUserList.sorted(by: {$0.name < $1.name})
        UserListCollectionView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let unselectedcell = tableView.cellForRow(at: indexPath) as! ChatUserListTableViewCell
        unselectedcell.selectedImageView.image = #imageLiteral(resourceName: "unSelected")
        let userID = users[indexPath.row].id
        let index = SelectedUserList.index(where: { $0.id == userID })
        SelectedUserList.remove(at: index!)
        SelectedUserMemberID.remove(at: index!)
        if SelectedUserList.count == 0 {
            userListCollectionViewHeightConstraint.constant = 0
        }
        UserListCollectionView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension AddGroupViewController :  UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SelectedUserList.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddGroupCollectionViewCell", for: indexPath) as! AddGroupCollectionViewCell
        cell.userImageView.sd_setImage(with: SelectedUserList[indexPath.item].profilePic, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        cell.userNameLbl.text = SelectedUserList[indexPath.item].name
        cell.deleteBtn.tag = indexPath.item
        cell.deleteBtn.addTarget(self, action: #selector(deleteBtnTap), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:75, height: 70)  
    }
    
    @objc func deleteBtnTap(sender:UIButton) {
        let userID = SelectedUserList[sender.tag].id
        let index = users.index(where: {$0.id == userID})
        let unselectedcell = UserListTableView.cellForRow(at: IndexPath(row: index!, section: 0)) as! ChatUserListTableViewCell
        UserListTableView.deselectRow(at: IndexPath(row: index!, section: 0), animated: true)
        unselectedcell.selectedImageView.image = #imageLiteral(resourceName: "unSelected")
        SelectedUserList.remove(at: sender.tag)
        SelectedUserMemberID.remove(at: sender.tag)
        if SelectedUserList.count == 0 {
            userListCollectionViewHeightConstraint.constant = 0
        }
        UserListCollectionView.reloadData()
    }
}

extension AddGroupViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
