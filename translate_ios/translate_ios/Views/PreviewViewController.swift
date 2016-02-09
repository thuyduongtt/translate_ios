//
//  PreviewViewController.swift
//  translate_ios
//
//  Created by Thuy Duong on 03.11.15.
//  Copyright © 2015 PiscesTeam. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController, MyUIImageViewDelegate {
    @IBOutlet weak var imageView: MyUIImageView!
    @IBOutlet weak var viewForm: UIView!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var aiLoadImage: UIActivityIndicatorView!
    var image: UIImage!
    var isAdded: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)        
        self.title = "Preview"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "btnCancelTapped")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "btnDoneTapped")
        
        imageView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        if let img = image {
            imageView.image = img
        }
        
        if (!Utilities.is35InchScreen()) {
            tfTitle.becomeFirstResponder()
        }
    }
    
    func imageSet() {
        aiLoadImage.stopAnimating()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        hideKeyboard()
    }
    
    @IBAction func hideKeyboard() {
        tfTitle.resignFirstResponder()
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
    
    func btnCancelTapped() {
        isAdded = false
        performSegueWithIdentifier("unwindToMyUploadSegue", sender: self)
    }
    
    func btnDoneTapped() {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Saving"
        Utilities.performAsync({
            let nsdate = NSDate()
            var tit = ""
            if (self.tfTitle.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != "") {
                tit = self.tfTitle.text!
            }
            else {
                tit = nsdate.format(.MediumStyle, timeStyle: .ShortStyle)
            }
            
            let imgName = "\(nsdate.timeStamp).jpg"
            self.saveImage(imgName)
            
            ModelManager.getInstance().addUpload(MyUploadItem(id: NSDate().currentTimeStamp, title: tit, uploadTime: NSDate(), imagePath: imgName))
            
            }, mainQueueAction: {
                hud.hide(true)
                self.isAdded = true
                self.performSegueWithIdentifier("unwindToMyUploadSegue", sender: self)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (!isAdded) {
            return
        }
        
        let vc = segue.destinationViewController as! MyUploadViewController
        vc.needReload = true
    }
    
    func saveImage(imgName: String) -> String {
        //        let imageData = UIImagePNGRepresentation(image)
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let path = Utilities.fileInImagesDirectory(imgName)
        let result = imageData!.writeToFile(path, atomically: true)
        
        if (result) {
            return path
        }
        
        return ""
    }
}
