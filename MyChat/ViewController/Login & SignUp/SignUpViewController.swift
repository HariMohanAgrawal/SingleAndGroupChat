//
//  SignUpViewController.swift
//  Amistos
//
//  Created by chawtech solutions on 3/22/18.
//  Copyright © 2018 chawtech solutions. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var NameTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    
    var fcmKey : String?
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    func registerFirebseWithUserNameEmailAndPass(userName:String,email:String,password:String) {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(self.view)
            User.registerUser(withName: userName, email: email, password: password, profilePic: userImageView.image!, token: (UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.FCM_Key) as? String)!) { [weak weakSelf = self] (status) in
                //DispatchQueue.main.async {
                //weakSelf?.showLoading(state: false)
                hideAllProgressOnView(self.view)
                if status == true {
                    print("succceeeeeeeeeeeesssssss..................")
                    self.loginFirebaseWithEmailAndPass(email: self.emailTxtField.text!, password: self.passwordTxtField.text!)
                }
                else {
                    print("erroooooooooooooooor..................")
                    self.loginFirebaseWithEmailAndPass(email: self.emailTxtField.text!, password: self.passwordTxtField.text!)
                }
            }
        }
        else{
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    
    func loginFirebaseWithEmailAndPass(email:String,password:String) {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(self.view)
            User.loginUser(withEmail: email, password: password) { (status,error)  in
                hideAllProgressOnView(self.view)
                if status == true {
                    UserDefaults.standard.set(true, forKey: USER_DEFAULTS_KEYS.IS_LOGIN)  
                    self.navigationController?.pushViewController(UIStoryboard.ChatUserListViewController(), animated: true)
                    
                } else {
                    UIAlertController.showInfoAlertWithTitle("Alert", message: "Error:\(error)", buttonTitle: "Okay")
                }
            }
        }
        else{
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
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
    
    @IBAction func registerButtonClicked(_ sender: Any) {
        if !(ValidationManager.validateUserFullName(name: NameTxtField.text!)) {
            showInvalidInputAlert(NameTxtField.placeholder!)
        }
        else if !(ValidationManager.validateEmail(email: emailTxtField.text!)) {
            showInvalidInputAlert(emailTxtField.placeholder!)
        } else if ValidationManager.validatePassword(password: passwordTxtField.text!) == 0 {
            showPasswordLengthAlert()
        } else if ValidationManager.validatePassword(password: passwordTxtField.text!) == 1 {
            showPasswordWhiteSpaceAlert()
        }
        else if Reachability.isConnectedToNetwork() {
            showProgressOnView(self.view)
            self.registerFirebseWithUserNameEmailAndPass(userName:NameTxtField.text! , email:emailTxtField.text! , password:passwordTxtField.text! )
            
            
        }else{
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    
    @IBAction func signInButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SignUpViewController {  
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == NameTxtField {
            NameTxtField.text = NameTxtField.text?.capitalized
        }
    }
}  

extension SignUpViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
