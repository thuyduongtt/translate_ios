//
//  MyUploadTableViewController.swift
//  translate_ios
//
//  Created by Thuy Duong on 15.11.15.
//  Copyright © 2015 PiscesTeam. All rights reserved.
//

import Foundation
import UIKit

protocol MyUploadTableDelegate: NSObjectProtocol {
    func didSelectedItem(item: MyUploadItem)
    func finishDeleting()
    func hasItemSelected()
    func noItemSelected()
}

class MyUploadTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private weak var lbNoUpload: UILabel!
    @IBOutlet private weak var uploadTableView: UITableView!
    
    private var myUploads: NSMutableArray? = nil
    private var selectedItem: MyUploadItem!
    private var isSwipeToDelete = false
    private var refreshControl: UIRefreshControl!
    
    var delegate: MyUploadTableDelegate!
    
    override func viewDidLoad() {
        myUploads = NSMutableArray()
        
        uploadTableView.delegate = self
        uploadTableView.dataSource = self
        uploadTableView.tableFooterView = UIView(frame: CGRectZero)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull down to refresh")
        refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        uploadTableView.addSubview(refreshControl)
        
        reloadFromDb()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (myUploads?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = uploadTableView.dequeueReusableCellWithIdentifier("UploadCell", forIndexPath: indexPath) as! MyUploadTableViewCell
        let item = myUploads![indexPath.row] as! MyUploadItem
        
        cell.title.text = item.title
        cell.subTitle.text = item.uploadTime!.format(.MediumStyle, timeStyle: .ShortStyle)
        cell.thumbnail.image = Utilities.loadImageWithName(item.imagePath!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (uploadTableView.editing) {
            if (tableView.indexPathsForSelectedRows?.count > 0) {
                if let d = delegate {
                    d.hasItemSelected()
                }
            }
            return
        }
        
        if (isSwipeToDelete) { //TD: bug here
            return
        }
        
        selectedItem = myUploads![indexPath.row] as! MyUploadItem
        
        if (!Utilities.isPad()) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        if let d = delegate {
            d.didSelectedItem(selectedItem)
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if (uploadTableView.editing) {
            if (tableView.indexPathsForSelectedRows?.count <= 0) {
                if let d = delegate {
                    d.noItemSelected()
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        isSwipeToDelete = true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let item = myUploads![indexPath.row] as! MyUploadItem
            ModelManager.getInstance().deleteUpload(item.id!)
            
            myUploads?.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            
            changeUIAfterDeletion()
        }
    }
    
    func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        isSwipeToDelete = false
    }
    
    func refresh() {
        refreshControl.endRefreshing()
        reloadFromDb()
        let alert = UIAlertView(title: "Refresh", message: "Refresh action fired", delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }

    func reloadFromDb() {
        myUploads = ModelManager.getInstance().getAllUploads()
        uploadTableView.reloadData()
        
        lbNoUpload.hidden = myUploads?.count > 0 ? true : false
    }
    
    func canEdited() -> Bool {
        if (myUploads?.count <= 0 || isSwipeToDelete) {
            return false
        }
        
        return true
    }
    
    func setEditingState(isEditing: Bool) {
        if (isEditing) {
            if (myUploads?.count <= 0 || isSwipeToDelete) {
                return
            }
            
            uploadTableView.setEditing(true, animated: true)
        }
        else {
            uploadTableView.setEditing(false, animated: true)
        }
    }
    
    func deleteRows() {
        var arrayOfId: [String] = []
        for indexPath in uploadTableView.indexPathsForSelectedRows! {
            let item = myUploads![indexPath.row] as! MyUploadItem
            arrayOfId.append(item.id!)
        }
        
        if (arrayOfId.count > 0) {
            ModelManager.getInstance().deleteMultiUploads(arrayOfId)
            reloadFromDb()
        }
        
        changeUIAfterDeletion()
    }
    
    private func changeUIAfterDeletion() {
        if (myUploads?.count <= 0) {
            lbNoUpload.hidden = false
            if let d = delegate {
                d.finishDeleting()
            }
        }
        else {
            lbNoUpload.hidden = true
            let rowToSelect:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0);  //selecting 0th row with 0th section
            self.uploadTableView.selectRowAtIndexPath(rowToSelect, animated: true, scrollPosition: UITableViewScrollPosition.Top)
            self.tableView(self.uploadTableView, didSelectRowAtIndexPath: rowToSelect)
        }
    }
}
