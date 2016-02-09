//
//  MyUploadViewController.swift
//  translate_ios
//
//  Created by Thuy Duong on 03/11/15.
//  Copyright © 2015 PiscesTeam. All rights reserved.
//

import UIKit

class MyUploadViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MyUploadTableDelegate {
    
    @IBOutlet private weak var leftView: UIView!
    @IBOutlet private weak var rightView: UIView!
    @IBOutlet private weak var trailingLeftViewConstraint: NSLayoutConstraint!
    
    private var tableVc: MyUploadTableViewController!
    private var detailVc: DetailViewController!
    private var resultImage: UIImage!
    private var popOver: UIPopoverController!
    private var selectedItem: MyUploadItem!
    
    private let rightViewCollapsedWidth: CGFloat = 0.0
    private let rightViewExpandedWidth: CGFloat = 450.0
    
    var needReload = false
    
    @IBAction func unwindToMyUploadViewController(unwindSegue: UIStoryboardSegue) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        if (unwindSegue.sourceViewController.isKindOfClass(DetailViewController)) {
            if (needReload) {
                needReload = false
                tableVc.reloadFromDb()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        setDefaultBarButtonItems()
    }
    
    func setDefaultBarButtonItems() {
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "btnAddTapped:"), animated: true)
        self.navigationItem.setRightBarButtonItems([UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "btnEditTapped"), UIBarButtonItem(image: UIImage(named:"iconSettings"), style: .Plain, target: self, action: "btnSettingTapped")], animated: true)
    }
    
    //MARK: MyUploadTableDelegate functions
    
    func didSelectedItem(item: MyUploadItem) {
        self.selectedItem = item
        if (Utilities.isPad()) {
            detailVc.myUploadItem = self.selectedItem
            if (self.trailingLeftViewConstraint.constant < (rightViewCollapsedWidth + 1.0)) {
                self.trailingLeftViewConstraint.constant = rightViewExpandedWidth
                UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                    }, completion: nil)
            }
        }
        else {
            performSegueWithIdentifier("fromMyUploadToDetail", sender: self)
        }
    }

    func btnAddTapped(sender: AnyObject) {
        if (Utilities.isPad()) {
            if #available(iOS 8.0, *) {
                let alertController = UIAlertController(title: "Choose your photo from...", message: nil, preferredStyle: .ActionSheet)
                alertController.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { alertAction in
                    // Handle Take Photo
                    self.showImagePicker(.Camera)
                }))
                alertController.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { alertAction in
                    // Handle Choose Existing Photo
                    self.showImagePicker(.PhotoLibrary)
                }))
                alertController.modalPresentationStyle = .Popover
                
                let popover = alertController.popoverPresentationController!
                popover.permittedArrowDirections = .Up
                let senderButton = sender as? UIBarButtonItem
                let senderView = senderButton?.valueForKey("view") as! UIView
                popover.sourceView = senderView
                popover.sourceRect = senderView.bounds
                
                presentViewController(alertController, animated: true, completion: nil)
                
                return
            }
        }
        
        let asheet = UIActionSheet(title: "Choose your photo from...", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Camera", "Photo Library")
        asheet.tag = 1
        asheet.showInView(self.view)
    }
    
    func btnEditTapped() {
        if (!tableVc.canEdited()) {
            return
        }
        
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "btnTrashTapped:"), animated: true)
        navigationItem.leftBarButtonItem?.enabled = false
        self.navigationItem.setRightBarButtonItems([UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "btnDoneTapped")], animated: true)
        
        tableVc.setEditingState(true)
    }
    
    func finishDeleting() {
        btnDoneTapped()
        
        if (self.trailingLeftViewConstraint.constant > (rightViewExpandedWidth - 1.0)) {
            self.trailingLeftViewConstraint.constant = rightViewCollapsedWidth
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    func hasItemSelected() {
        navigationItem.leftBarButtonItem?.enabled = true
    }
    
    func noItemSelected() {
        navigationItem.leftBarButtonItem?.enabled = false
    }
    
    //MARK: Button handler
    func btnTrashTapped(sender: AnyObject) {
        if (Utilities.isPad()) {
            if #available(iOS 8.0, *) {
                let alertController = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .ActionSheet)
                alertController.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { alertAction in
                    self.tableVc.deleteRows()
                }))
                
                alertController.modalPresentationStyle = .Popover
                
                let popover = alertController.popoverPresentationController!
                popover.permittedArrowDirections = .Up
                let senderButton = sender as? UIBarButtonItem
                let senderView = senderButton?.valueForKey("view") as! UIView
                popover.sourceView = senderView
                popover.sourceRect = senderView.bounds
                
                presentViewController(alertController, animated: true, completion: nil)
                
                return
            }
        }
        
        let asheet = UIActionSheet(title: "Are you sure?", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Delete")
        asheet.tag = 2
        asheet.showInView(self.view)
    }
    
    func btnDoneTapped() {
        setDefaultBarButtonItems()
        tableVc.setEditingState(false)
    }
    
    func btnSettingTapped() {
        performSegueWithIdentifier("fromMainToSettingSegue", sender: self)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (actionSheet.tag == 1) {
            if (buttonIndex == 1) {
                showImagePicker(.Camera)
            }
            else if (buttonIndex == 2) {
                showImagePicker(.PhotoLibrary)
            }
        }
        else if (actionSheet.tag == 2) {
            if (buttonIndex == 0) {
                tableVc.deleteRows()
            }
        }
    }
    
    func showImagePicker(sourceType: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = sourceType
        
        if (sourceType == .PhotoLibrary && Utilities.isPad()) {
            popOver = UIPopoverController(contentViewController: picker)
            popOver.presentPopoverFromBarButtonItem(self.navigationItem.leftBarButtonItem!, permittedArrowDirections: .Any, animated: true)
        }
        else {
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            resultImage = pickedImage
            performSegueWithIdentifier("fromMainToPreview", sender: self)
        }
        
        if (popOver != nil) {
            popOver.dismissPopoverAnimated(true)
            popOver = nil
        }
        else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        if (popOver != nil) {
            popOver.dismissPopoverAnimated(true)
            popOver = nil
        }
        else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController
        
        if (segue.identifier == "MyUploadTableEmbedSegue") {
            tableVc = vc as! MyUploadTableViewController
            tableVc.delegate = self
        }
        
        if (Utilities.isPad()) {
            if (segue.identifier == "DetailEmbedSegue") {
                detailVc = vc as! DetailViewController
            }
        }
        else if (vc.isKindOfClass(DetailViewController) && (self.selectedItem != nil)) {
            let vcc = segue.destinationViewController as! DetailViewController
            vcc.myUploadItem = self.selectedItem
        }
        
        if (vc.isKindOfClass(PreviewViewController)) {
            let vcc = vc as! PreviewViewController
            vcc.image = resultImage
        }
        
    }
}
