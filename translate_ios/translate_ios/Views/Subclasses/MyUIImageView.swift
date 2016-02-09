//
//  MyUIImageView.swift
//  translate_ios
//
//  Created by Thuy Duong on 16.11.15.
//  Copyright © 2015 PiscesTeam. All rights reserved.
//

import UIKit

protocol MyUIImageViewDelegate: NSObjectProtocol {
    func imageSet()
}

class MyUIImageView: UIImageView {
    var delegate: MyUIImageViewDelegate!
    
    override var image: UIImage? {
        didSet {
            if (image != nil) {
                if let d = delegate {
                    d.imageSet()
                }
            }
//            else {
//                
//            }
        }
    }
}
