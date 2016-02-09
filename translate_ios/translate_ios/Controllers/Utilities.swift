//
//  Utilities.swift
//  translate_ios
//
//  Created by Thuy Duong on 25/10/15.
//  Copyright © 2015 PiscesTeam. All rights reserved.
//

import Foundation
import UIKit

class Utilities: NSObject {
    static func moveViewVertically(view: UIView, distance: CGFloat) {
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                let viewFormFrame = view.frame
                view.frame = CGRectMake(viewFormFrame.origin.x, viewFormFrame.origin.y +  distance, viewFormFrame.size.width, viewFormFrame.size.height)
            }, completion: nil)
    }
    
    static func is35InchScreen() -> Bool {
//        print(UIScreen.mainScreen().bounds.height)
        if UIDevice().userInterfaceIdiom == .Phone {
//            switch UIScreen.mainScreen().nativeBounds.height {
//            case 480:
//                print("iPhone Classic")
//            case 960:
//                print("iPhone 4 or 4S")
//            case 1136:
//                print("iPhone 5 or 5S or 5C")
//            case 1334:
//                print("iPhone 6 or 6S")
//            case 2208:
//                print("iPhone 6+ or 6S+")
//            default:
//                print("unknown")
//            }
            return UIScreen.mainScreen().bounds.height <= 480
        }
        return false
    }
    
    private static func documentsDirectory() -> String {
//        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let documentsURL = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        return documentsURL
    }
    
    static func imagesDirectory() -> String {
        return documentsDirectory().stringByAppendingPathComponent("images")
    }
    
    static func fileInDocumentsDirectory(filename: String) -> String {
        return documentsDirectory().stringByAppendingPathComponent(filename)
    }
    
    static func fileInImagesDirectory(filename: String) -> String {
        let imgFolderName = "images"
        let imgDirectory = documentsDirectory().stringByAppendingPathComponent(imgFolderName)
        do {
            if (!NSFileManager.defaultManager().fileExistsAtPath(imgDirectory)) {
                try NSFileManager.defaultManager().createDirectoryAtPath(imgDirectory, withIntermediateDirectories: false, attributes: nil)
            }
        }
        catch {}

        return imgDirectory.stringByAppendingPathComponent(filename)
    }
    
    /*
    
    NSSearchPathForDirectoriesInDomains returns the file path. It takes argument as follows:
    NSSearchPathDirectory - it specifies a location for various directories.
    NSSearchPathDomainMask - it specifies base location for NSSearchPathDirectory type.
    expandedTilde – if set to YES then tildes are expanded.
    */
    static func getPath(fileName: String) -> String {
        let fileURL = documentsDirectory().stringByAppendingPathComponent(fileName)
        return fileURL
    }
    
    /*
    You can use NSFileManager class on File and directories for following operations Locate, Create, Copy, Move. It provides copyItemAtPath() function to copy files from source to destination.
    */
    static func copyFile(fileName: NSString) {
        let dbPath: String = getPath(fileName as String)
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(dbPath) {
            
            let documentsURL = NSBundle.mainBundle().resourceURL
            let fromPath = documentsURL!.URLByAppendingPathComponent(fileName as String)
            
            var error : NSError?
            do {
                try fileManager.copyItemAtPath(fromPath.path!, toPath: dbPath)
            } catch let error1 as NSError {
                error = error1
            }
            let alert: UIAlertView = UIAlertView()
            if (error != nil) {
                alert.title = "Error Occured"
                alert.message = error?.localizedDescription
            } else {
                alert.title = "Successfully Copy"
                alert.message = "Your database copy successfully"
            }
            alert.delegate = nil
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
    }
    
    static func convertToDate(timeStamp: String) -> NSDate {
        let i = Double(timeStamp)! / 1000
        return NSDate(timeIntervalSince1970: NSTimeInterval(i))
    }
    
    static func loadImageWithName(imgName: String) -> UIImage? {
        let image = UIImage(contentsOfFile: Utilities.imagesDirectory().stringByAppendingPathComponent(imgName))
        
        if image == nil {
            print("missing image at: (path)")
        }
        
        return image
    }
    
    static func isPad() -> Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }
    
    static var GlobalMainQueue: dispatch_queue_t {
        return dispatch_get_main_queue()
    }
    
    @available(iOS 8.0, *)
    static var GlobalUserInteractiveQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
    }
    
    @available(iOS 8.0, *)
    static var GlobalUserInitiatedQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
    }
    
    @available(iOS 8.0, *)
    static var GlobalUtilityQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)
    }
    
    @available(iOS 8.0, *)
    static var GlobalBackgroundQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
    }
    
    static var GlobalPriorityBackgroundQueue: dispatch_queue_t {
        return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
    }
    
    static func performAsync(backgroundAction: (() -> Void)!, mainQueueAction: (() -> Void)!) {
        if #available(iOS 8.0, *) {
            if (backgroundAction != nil) {
                dispatch_async(GlobalUserInteractiveQueue, {
                    backgroundAction()
                    
                    if ((mainQueueAction) != nil) {
                        dispatch_async(dispatch_get_main_queue(), {
                            mainQueueAction()
                        })
                    }
                })
            }
            else {
                if ((mainQueueAction) != nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        mainQueueAction()
                    })
                }
            }
        } else {
            if (backgroundAction != nil) {
                dispatch_async(GlobalPriorityBackgroundQueue, {
                    backgroundAction()
                    
                    if ((mainQueueAction) != nil) {
                        dispatch_async(dispatch_get_main_queue(), {
                            mainQueueAction()
                        })
                    }
                })
            }
            else {
                if ((mainQueueAction) != nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        mainQueueAction()
                    })
                }
            }
        }
    }
}