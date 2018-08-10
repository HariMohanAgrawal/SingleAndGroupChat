//
//  ChatUserListViewController.swift
//  Amistos
//
//  Created by Amit on 03/07/18.
//  Copyright © 2018 chawtech solutions. All rights reserved.
//

import UIKit
import Firebase
import DropDown

class Global {
   static var items = [User]()
}

class ChatUserListViewController: UIViewController {
    @IBOutlet weak var CustomNavigationBar: CustomNavigationBar!
    @IBOutlet weak var ChatUserListTableView: UITableView!
    @IBOutlet weak var NoMemberLbl: UILabel!
    let amountDropDown = DropDown()
    var optionList = ["Create Group", "Logout"]
  
    var groupStore = [Group]()
    var userStore = [User]()
    var currentUser : User?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
         
        CustomNavigationBar.hideLeftBarButtonItem()
        CustomNavigationBar.imgViewLeadingConstraint.constant = 10    
        CustomNavigationBar.titleLeadingConstraint.constant = 10 + 50 + 8
        ChatUserListTableView.tableFooterView = UIView()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        CustomNavigationBar.imgView.isUserInteractionEnabled = true
        CustomNavigationBar.imgView.addGestureRecognizer(tapGestureRecognizer)
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.fetchGroups()
        self.fetchUsers()  
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let viewController = UIStoryboard.UpdateUserProfileViewController()
        viewController.selectedUser = currentUser
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {  
        super.didReceiveMemoryWarning()
    }  
    
    func customizeDropDown(_ sender: AnyObject) {  
        let appearance = DropDown.appearance()
        
        appearance.cellHeight = 60
        appearance.backgroundColor = UIColor(white: 1, alpha: 1)
        appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        appearance.cornerRadius = 10
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 25  
        appearance.animationduration = 0.25
        appearance.textColor = .darkGray
        
        dropDowns.forEach {
            /*** FOR CUSTOM CELLS ***/
            $0.cellNib = UINib(nibName: "MyCell", bundle: nil)
            
            $0.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                guard let cell = cell as? MyCell else { return }
                
                // Setup your custom UI components
                cell.suffixLabel.text = "Suffix \(index)"
            }
            /*** ---------------- ***/
        }
    }
    lazy var dropDowns: [DropDown] = {
        return [
            self.amountDropDown
            
        ]
    }()
    
    func setupAmountDropDown(arr:[String],btn:UIButton) {
        //amountDropDown.show()
        amountDropDown.anchorView = btn
        amountDropDown.bottomOffset = CGPoint(x: 0, y: btn.bounds.height + 10)
        
        // var idNum:Int = 0
        amountDropDown.dataSource = arr
        amountDropDown.show()
        amountDropDown.selectionAction = { [unowned self] (index, item) in
            // let intValue : Int? = index
            switch index {
            case 0:
                let viewController = UIStoryboard.AddGroupViewController()
                viewController.users = self.userStore
                self.navigationController?.pushViewController(viewController, animated: true)
                break
            case 1:
                let Alert = UIAlertController(title: "Alert!", message: "Are You Sure, You Want To Logout.", preferredStyle: UIAlertControllerStyle.alert)
                Alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                    logoutUser()
                }))
                Alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(Alert, animated: true, completion: nil)
                break
            default:
                break
            }
        }
    }  
        
    //MARK:- Fetch firebase user list
    func fetchUsers()  {
        Global.items.removeAll()
        self.userStore.removeAll()
        if let id = Auth.auth().currentUser?.uid {
            User.downloadAllUsers(completion: {(user) in
                DispatchQueue.main.async {
                    Global.items.append(user)  // save all user with me also.
                    if user.id != id {
                        self.userStore.append(user)  //save all user except me.
                        print("User Name: \(user.name)")
                        self.userStore = self.userStore.sorted(by: { $0.name < $1.name })
                        self.ChatUserListTableView.reloadData()
                    }
                    else {
                        self.currentUser = user
                        UserDefaults.standard.setValue(user.name, forKey: USER_DEFAULTS_KEYS.Login_User_Name)
                        self.CustomNavigationBar.titleLabel.text = user.name
                        self.CustomNavigationBar.imgView.sd_setImage(with: user.profilePic, placeholderImage: #imageLiteral(resourceName: "placeholder"))
                        self.CustomNavigationBar.subTitleLabel.text = user.email
                    }
                }
            })
        }  
    }  
      
    func fetchGroups() {
        self.groupStore.removeAll()
        if (Auth.auth().currentUser?.uid) != nil {
            Group.loadGroups(completionHandler: {(group) in
                DispatchQueue.main.async {
                    self.groupStore.append(group)
                    print("Group Name: \(group.groupName!)")
                    self.groupStore = self.groupStore.sorted(by: { $0.groupName! < $1.groupName! })
                    self.ChatUserListTableView.reloadData()  
                }  
            })  
        }
    }
    
    @IBAction func settingBtnTap(_ sender: UIButton) {
        self.setupAmountDropDown(arr: optionList, btn: sender)
    }
}

extension ChatUserListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userStore.count + groupStore.count
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatUserListTableViewCell") as! ChatUserListTableViewCell
        if indexPath.row < groupStore.count {
            cell.MemberImageView.sd_setImage(with: groupStore[indexPath.row].groupImage, placeholderImage: #imageLiteral(resourceName: "placeholder"))
            cell.MemberNameLbl.text = groupStore[indexPath.row].groupName
        }
        else {
            cell.MemberImageView.sd_setImage(with:self.userStore[indexPath.row - groupStore.count].profilePic, placeholderImage: #imageLiteral(resourceName: "placeholder"))
            cell.MemberNameLbl.text = self.userStore[indexPath.row - groupStore.count].name
        }
        cell.selectedImageView.isHidden = true  
        return cell  
    }
}  

extension ChatUserListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < groupStore.count {
            let groupName = groupStore[indexPath.row].groupName
            if self.groupStore.count > 0 {
                for i in 0..<self.groupStore.count {
                    if self.groupStore[i].groupName == groupName {
                        let storyboard = UIStoryboard(name: "Firebase", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier :"Chat") as! ChatVC
                        vc.currentGroup = self.groupStore[i]
                        vc.currentUserName =  groupName!
                        self.navigationController?.pushViewController(vc, animated: true)
                    }   
                }
            }  
        }
        else {
            let userEmail = self.userStore[indexPath.row - groupStore.count].email
            let userName = self.userStore[indexPath.row - groupStore.count].name
            if self.userStore.count > 0 {
                for i in 0..<self.userStore.count {
                    if self.userStore[i].email == userEmail {
                        let storyboard = UIStoryboard(name: "Firebase", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier :"Chat") as! ChatVC
                        vc.currentUser = self.userStore[i]
                        vc.currentUserName =  userName
                        self.navigationController?.pushViewController(vc, animated: true)
                        return
                    }
                }
            }
        }    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
