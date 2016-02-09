//
//  DetailViewController.swift
//  translate_ios
//
//  Created by Thuy Duong on 03.11.15.
//  Copyright © 2015 PiscesTeam. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, MWPhotoBrowserDelegate, MyUIImageViewDelegate {
    @IBOutlet weak var imageView: MyUIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubtitle: UILabel!
    @IBOutlet weak var lbSubtitle2: UILabel!
    @IBOutlet weak var aiLoadImage: UIActivityIndicatorView!
    var myUploadItem: MyUploadItem! {
        didSet {
            if (!isLoaded) {
                return
            }
            
            Utilities.performAsync(loadUI, mainQueueAction: {
                self.imageView.image = self.image
            })
        }
    }
    private var photos: NSArray!
    private var isLoaded = false
    private var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapInImageView")
        
        imageView.addGestureRecognizer(tapGesture)
        imageView.delegate = self
        isLoaded = true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = "Detail"
        
        if (myUploadItem != nil) {
            Utilities.performAsync(loadUI, mainQueueAction: {
                self.imageView.image = self.image
            })
        }
    }
    
    func loadUI() {
        lbTitle.text = myUploadItem.title
        lbSubtitle.text = myUploadItem.uploadTime!.format(.MediumStyle, timeStyle: .ShortStyle)
//        lbSubtitle2.text = myUploadItem.uploader?.email
        image = Utilities.loadImageWithName(myUploadItem.imagePath!)
        photos = [MWPhoto(image: image)]
    }
    
    func imageSet() {
        aiLoadImage.stopAnimating()
    }
    
    func tapInImageView() {
        if (photos == nil) {
            return
        }
        
        let browser = MWPhotoBrowser(delegate: self)
        self.navigationController?.pushViewController(browser, animated: true)
    }
    
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return 1
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        if Int(index) < self.photos.count {
            return photos.objectAtIndex(Int(index)) as! MWPhoto
        }
        
        return nil
    }
    
    //TODO: re-check here
//    override func viewDidDisappear(animated: Bool) {
//        if let img = imageView {
//            if let _ = img.image {
//                img.image = nil
//            }
//            imageView = nil
//        }
//    }
}
