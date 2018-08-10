//
//  UpdateUserProfileViewController.swift
//  MyChat
//
//  Created by Amit on 17/07/18.
//  Copyright © 2018 Amit. All rights reserved.
//

import UIKit

class UpdateUserProfileViewController: UIViewController {
    @IBOutlet weak var CustomNavigationBar: CustomNavigationBar!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var NameTxtField: UITextField!
    var selectedUser: User?
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        CustomNavigationBar.titleLabel.text = selectedUser?.name
        CustomNavigationBar.subTitleLabel.text = selectedUser?.email

        CustomNavigationBar.imgView.isHidden = true
        CustomNavigationBar.titleLeadingConstraint.constant = 10 + 30 + 8
        userImageView.sd_setImage(with: selectedUser?.profilePic, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        NameTxtField.text = selectedUser?.name
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
    
    @IBAction func saveChangesBtnTap(_ sender: Any) {
        showProgressOnView(self.view)
        User.updateUser(Name: NameTxtField.text!,email:(selectedUser?.email)!, profilePic: userImageView.image!, token : (UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.FCM_Key) as? String)!, completion: { (status) in
            if status == true {
                hideAllProgressOnView(self.view)
                for controller: Any? in self.navigationController?.viewControllers ?? [Any?]() {
                    if (controller is ChatUserListViewController) {
                        if let aController = controller as? UIViewController {
                            self.navigationController?.popToViewController(aController, animated: true)
                        }
                    }  
                }
            }
        })
    }
}

extension UpdateUserProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
