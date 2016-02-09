//
//  SignUpViewController.swift
//  translate_ios
//
//  Created by Thuy Duong on 25/10/15.
//  Copyright © 2015 PiscesTeam. All rights reserved.
//

import Foundation
import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var btnCreateAccount: UIButton!
    @IBOutlet weak var viewForm: UIView!
    
    @IBAction func btnHideKeyboardPressed() {
        hideKeyboard()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        if (!Utilities.is35InchScreen()) {
            tfEmail.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        hideKeyboard()
    }
    
    func hideKeyboard() {
        tfEmail.resignFirstResponder()
        tfPassword.resignFirstResponder()
        tfConfirmPassword.resignFirstResponder()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if (Utilities.is35InchScreen()) {
            Utilities.moveViewVertically(viewForm, distance: -110)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (Utilities.is35InchScreen()) {
            Utilities.moveViewVertically(viewForm, distance: 110)
        }
    }
    
    @IBAction func tfEditingChanged(sender: AnyObject) {
        checkForm()
    }
    
    func checkForm() {
        if (tfEmail.text!.isEmpty || tfPassword.text!.isEmpty || tfConfirmPassword.text!.isEmpty) {
            btnCreateAccount.enabled = false
            return
        }
        
        if (tfPassword.text! != tfConfirmPassword.text!) {
            btnCreateAccount.enabled = false
            return
        }
        
        btnCreateAccount.enabled = true
    }
    
    @IBAction func btnCreateAccountPressed() {
        performSegueWithIdentifier("fromSignUpToMain", sender: self)
        return
        
        let result = ConnectionManager.translateServer.userRegister(User(username: "", password: tfPassword.text, email: tfEmail.text))
        if (result == 1) {
            performSegueWithIdentifier("fromSignUpToMain", sender: self)
        }
        else {
            let alertView = UIAlertView(title: "Error", message: "result = 0", delegate: self, cancelButtonTitle: "OK")
            alertView.show()
        }
    }
}
