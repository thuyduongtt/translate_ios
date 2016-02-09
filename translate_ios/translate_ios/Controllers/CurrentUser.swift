//
//  CurrentUser.swift
//  translate_ios
//
//  Created by Thuy Duong on 21.11.15.
//  Copyright © 2015 PiscesTeam. All rights reserved.
//

import UIKit

let currentUser = CurrentUser()

class CurrentUser: NSObject {
    
    var email: String = ""
    var password: String = ""
    
    class func getInstance() -> CurrentUser {
        return currentUser
    }
}
