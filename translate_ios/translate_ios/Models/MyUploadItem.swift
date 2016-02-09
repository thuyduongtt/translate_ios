//
//  MyUploadItem.swift
//  translate_ios
//
//  Created by Thuy Duong on 03/11/15.
//  Copyright © 2015 PiscesTeam. All rights reserved.
//

import UIKit

class MyUploadItem: NSObject {
    var id: String?
    var title: String?
    var uploadTime: NSDate?
//    var uploader: Uploader?
    var imagePath: String?
    
    init(id:String?, title: String?, uploadTime: NSDate?, imagePath: String?) {
        self.id = id
        self.title = title
        self.uploadTime = uploadTime
//        self.uploader = uploader
        self.imagePath = imagePath
    }
}
