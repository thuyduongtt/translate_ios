//
//  ModelManager.swift
//  translate_ios
//
//  Created by Thuy Duong on 07.11.15.
//  Copyright © 2015 PiscesTeam. All rights reserved.
//

import UIKit

let sharedInstance = ModelManager()

class ModelManager: NSObject {
    
    var database: Connection? = nil
    
    let myuploads = Table("myuploads")
    let id = Expression<String>("id")
    let title = Expression<String>("title")
    let uploadtime = Expression<String>("uploadtime")
    let uploaderemail = Expression<String>("uploaderemail")
    let imagePath = Expression<String>("imagePath")
    
    class func getInstance() -> ModelManager {
        if (sharedInstance.database == nil) {
            do {
                sharedInstance.database = try Connection(Utilities.getPath("TranslateDb.sqlite"))
            }
            catch {
                
            }
        }
        return sharedInstance
    }
    
    func addUpload(myUpload: MyUploadItem) -> Int64 {
        do {
            let rowid = try sharedInstance.database!.run(myuploads.insert(
                id <- myUpload.id!,
                title <- myUpload.title!,
                uploadtime <- (myUpload.uploadTime?.timeStamp)!,
                uploaderemail <- "",
                imagePath <- myUpload.imagePath!))
            
            return rowid
        }
        catch {}
        return -1
    }
    
    func getAllUploads() -> NSMutableArray {
        let arr : NSMutableArray = NSMutableArray()
        for u in sharedInstance.database!.prepare(myuploads) { //TODO: add "try" here
            let upload = MyUploadItem(id: u[id], title: u[title], uploadTime: Utilities.convertToDate(u[uploadtime]), imagePath: u[imagePath])
            arr.addObject(upload)
        }
        return arr
    }

    func deleteUpload(idToDelete: String) {
        let deleted = myuploads.filter(id == idToDelete)
        do {
            try sharedInstance.database!.run(deleted.delete())
        }
        catch {}
    }
    
    func deleteMultiUploads(arrayOfId: [String]) {
        let deleted = myuploads.filter(arrayOfId.contains(id))
        do {
            try sharedInstance.database!.run(deleted.delete())
        }
        catch {}
    }
}
