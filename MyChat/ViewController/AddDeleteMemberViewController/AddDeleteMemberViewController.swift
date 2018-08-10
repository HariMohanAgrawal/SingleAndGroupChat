//
//  AddDeleteMemberViewController.swift
//  MyChat
//
//  Created by Amit on 14/07/18.
//  Copyright © 2018 Amit. All rights reserved.
//

import UIKit
import Firebase

class AddDeleteMemberViewController: UIViewController {
    @IBOutlet weak var CustomNavigationBar: CustomNavigationBar!
    @IBOutlet weak var GroupMemberListTableView: UITableView!
    var memberList = [User]()
    var selectedGroup : Group?
    var addBool:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CustomNavigationBar.titleLabel.text = selectedGroup?.groupName
        CustomNavigationBar.imgView.sd_setImage(with: selectedGroup?.groupImage, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        GroupMemberListTableView.tableFooterView = UIView()
        GroupMemberListTableView.reloadData()  
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension AddDeleteMemberViewController: UITableViewDataSource {
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
        if addBool == true {
            cell.selectedImageView.image = #imageLiteral(resourceName: "plus")
        }
        else {
            cell.selectedImageView.image = #imageLiteral(resourceName: "cross")
        }
        cell.selectedImageView.isHidden = false
        return cell
    }
}

extension AddDeleteMemberViewController: UITableViewDelegate {
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {  
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if addBool == true {
            let Alert = UIAlertController(title: "Alert!", message: "Are you sure, You want to Add \(memberList[indexPath.row].name) Member in this group.", preferredStyle: UIAlertControllerStyle.alert)
            Alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                Group.addMemberInGroup(membersID: self.memberList[indexPath.row].id, groupId: (self.selectedGroup?.groupID)!, completion: { (status) in
                    if status == true {
                        for controller: Any? in self.navigationController?.viewControllers ?? [Any?]() {
                            if (controller is ChatUserListViewController) {
                                if let aController = controller as? UIViewController {
                                    self.navigationController?.popToViewController(aController, animated: true)
                                }  
                            }
                        }
                        UIAlertController.showInfoAlertWithTitle("Success!", message: "Member added successfully!", buttonTitle: "Okay")
                    }
                })
            }))
            Alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            present(Alert, animated: true, completion: nil)
        }
        else {
            let Alert = UIAlertController(title: "Alert!", message: "Are you sure, You want to Delete \(memberList[indexPath.row].name) Member in this group.", preferredStyle: UIAlertControllerStyle.alert)
            Alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                Group.deleteMemberInGroup(membersID: self.memberList[indexPath.row].id, groupId: (self.selectedGroup?.groupID)!, completion: { (status) in
                    if status == true {
                        for controller: Any? in self.navigationController?.viewControllers ?? [Any?]() {
                            if (controller is ChatUserListViewController) {
                                if let aController = controller as? UIViewController {
                                    self.navigationController?.popToViewController(aController, animated: true)
                                }
                            }
                        }
                        UIAlertController.showInfoAlertWithTitle("Success!", message: "Member removed successfully!", buttonTitle: "Okay")
                    }
                })
            }))
            Alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            present(Alert, animated: true, completion: nil)
        }
    }
}
