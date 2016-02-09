//
//  MyUploadTableViewCell.swift
//  translate_ios
//
//  Created by Thuy Duong on 06.11.15.
//  Copyright © 2015 PiscesTeam. All rights reserved.
//

import UIKit

class MyUploadTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
