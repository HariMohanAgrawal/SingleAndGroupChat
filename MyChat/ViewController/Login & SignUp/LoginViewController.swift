//
//  LoginViewController.swift
//  Amistos
//
//  Created by chawtech solutions on 3/22/18.
//  Copyright © 2018 chawtech solutions. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var userEmailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    var fcmKey : String?  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.isNavigationBarHidden = true
    }  
      
    override func viewDidLoad() {
        super.viewDidLoad()
    }
          
    func loginFirebaseWithEmailAndPass(email:String,password:String) {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(self.view)
            User.loginUser(withEmail: email, password: password) { (status,error)  in
                hideAllProgressOnView(self.view)
                if status == true {
                    UserDefaults.standard.set(true, forKey: USER_DEFAULTS_KEYS.IS_LOGIN)
                    appDelegateInstance.updateFCMAPI(tokenKey: UserDefaults.standard.value(forKey: USER_DEFAULTS_KEYS.FCM_Key) as! String)
                    self.navigationController?.pushViewController(UIStoryboard.ChatUserListViewController(), animated: true)
                }
                else {
                    UIAlertController.showInfoAlertWithTitle("Login Failed", message: "Error: \(error)", buttonTitle: "Okay")  
                }  
            }
        }
        else{
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
     
    @IBAction func loginButtonClicked(_ sender: Any) {
        if !(ValidationManager.validateEmail(email: userEmailTxtField.text!)) {
            showInvalidInputAlert(userEmailTxtField.placeholder!)
        } else if ValidationManager.validatePassword(password: passwordTxtField.text!) == 0 {
            showPasswordLengthAlert()
        } else if ValidationManager.validatePassword(password: passwordTxtField.text!) == 1 {
            showPasswordWhiteSpaceAlert()
        }
        else if Reachability.isConnectedToNetwork() {
            showProgressOnView(self.view)
            if let objFcmKey = UserDefaults.standard.object(forKey: USER_DEFAULTS_KEYS.FCM_Key) as? String {
                self.fcmKey = objFcmKey
            }
            self.loginFirebaseWithEmailAndPass(email: self.userEmailTxtField.text!, password: self.passwordTxtField.text!)
        }
    }
    
    @IBAction func registeredButtonClicked(_ sender: Any) {
        self.navigationController?.pushViewController(UIStoryboard.SignUpViewController(), animated: true)
    }
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        let forgotPasswordAlert = UIAlertController(title: "Forgot password?", message: "Enter email address", preferredStyle: .alert)
        forgotPasswordAlert.addTextField { (textField) in
            textField.placeholder = "Enter email address"
        }
        forgotPasswordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        forgotPasswordAlert.addAction(UIAlertAction(title: "Reset Password", style: .default, handler: { (action) in
            let resetEmail = forgotPasswordAlert.textFields?.first?.text
            showProgressOnView(self.view)
            User.forgotPassword(emailStr: resetEmail!) { (status,error) in
                hideAllProgressOnView(self.view)
                if status == true {
                    hideAllProgressOnView(self.view)
                    let resetEmailSentAlert = UIAlertController(title: "Reset email sent successfully", message: "Check your email", preferredStyle: .alert)
                    resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetEmailSentAlert, animated: true, completion: nil)
                    
                } else {
                    hideAllProgressOnView(self.view)
                    let resetFailedAlert = UIAlertController(title: "Reset Failed", message: "Error: \(error)", preferredStyle: .alert)
                    resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetFailedAlert, animated: true, completion: nil)
                }
            }
        }))
        self.present(forgotPasswordAlert, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

