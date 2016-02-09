//
//  SignInViewController.swift
//  translate_ios
//
//  Created by Thuy Duong on 25/10/15.
//  Copyright © 2015 PiscesTeam. All rights reserved.
//

import Foundation
import UIKit

class SignInViewController: UIViewController {
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var viewForm: UIView!
    
    @IBAction func unwindToSignInViewController(unwindSegue: UIStoryboardSegue) {
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
    @IBAction func btnHideKeyboardPressed() {
        hideKeyboard()
    }
    
    func hideKeyboard() {
        tfEmail.resignFirstResponder()
        tfPassword.resignFirstResponder()
    }
    
    func keyboardWillShow(notification: NSNotification) {
//        // Step 1: Get the size of the keyboard.
//        let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
//        print("\(keyboardSize?.height)")
//        
//        
//        // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
//        let contentInsets = UIEdgeInsetsMake(0, 0, (keyboardSize?.height)!, 0)
//        svBig.contentInset = contentInsets
//        svBig.scrollIndicatorInsets = contentInsets
//        
//        
//        // Step 3: Scroll the target text field into view.
//        var aRect = self.view.frame
//        aRect.size.height -= (keyboardSize?.height)!
//        if (!CGRectContainsPoint(aRect, tfPassword.frame.origin)) {
//            let scrollPoint = CGPointMake(0, tfPassword.frame.origin.y - ((keyboardSize?.size.height)! - 15))
//            svBig.setContentOffset(scrollPoint, animated: true)
//        }
        
        if (Utilities.is35InchScreen()) {
            Utilities.moveViewVertically(viewForm, distance: -65)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (Utilities.is35InchScreen()) {
            Utilities.moveViewVertically(viewForm, distance: 65)
        }
    }
    @IBAction func tfEditingChanged(sender: AnyObject) {
        checkForm()
    }
    
    func checkForm() {
        if (tfEmail.text!.isEmpty || tfPassword.text!.isEmpty) {
            btnSignIn.enabled = false
            return
        }
        
        btnSignIn.enabled = true
    }
    
    @IBAction func btnSignInPressed() {
        //TODO: remove these lines to test register form
        CurrentUser.getInstance().email = tfEmail.text!
        CurrentUser.getInstance().password = tfPassword.text!
        performSegueWithIdentifier("fromSignInToMain", sender: self)
        return
        
        let result = ConnectionManager.translateServer.userLogin(User(username: "", password: tfPassword.text, email: tfEmail.text))
        if (result == 1) {
            performSegueWithIdentifier("fromSignInToMain", sender: self)
        }
        else {
            let alertView = UIAlertView(title: "Error", message: "result = 0", delegate: self, cancelButtonTitle: "OK")
            alertView.show()
        }
    }
    
    
}