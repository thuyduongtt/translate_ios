//
//  PopupBannerView.swift
//  translate_ios
//
//  Created by Thuy Duong on 01/11/15.
//  Copyright © 2015 PiscesTeam. All rights reserved.
//

import Foundation
import UIKit


class PopupBannerViewController: UIViewController {
    
    enum BannerStyles {
        case Hidden
        case Success
        case Warning
        case Error
        case Infor
    }
    
    @IBOutlet weak var lbMessage: UILabel!
    
    private enum ActionAfterHiding {
        case None
        case Show
        case ShowThenHide
    }
    
    private var timer: NSTimer!
    private var isShowing = false
    
    private let successMessage = "Network connected"
    private let warningMessage = "Warning..."
    private let errorMessage = "No network connection"
    private let animationDuration = 0.2 //animation duration of show and hide effect
    private let animationPause = 2.0 //animation duration of showThenHide effect
    
    private var actionAfterHiding: ActionAfterHiding = .None
    private var styleAfterHiding: BannerStyles!
    private var messageToShowAfterHiding = ""
    
    var style: BannerStyles = .Hidden
    
    override func viewWillAppear(animated: Bool) {
        if (Reachability.isConnectedToNetwork()) {
            style = .Hidden
            isShowing = false
        }
        else {
            style = .Error
            isShowing = true
        }
        
        setText()
        setColor()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "checkNetwork", userInfo: nil, repeats: true)
    }
    
    func checkNetwork() {
        if (Reachability.isConnectedToNetwork() && isShowing && style != .Success) {
            style = .Success
            doAnimation()
        }
        else if (!Reachability.isConnectedToNetwork() && style != .Error) {
            style = .Error
            doAnimation()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        timer.invalidate()
        timer = nil
    }
    
    private func setText() {
        switch style {
        case .Success:
            lbMessage.text = successMessage
        case .Warning:
            lbMessage.text = warningMessage
        case .Error:
            lbMessage.text = errorMessage
        default:
            lbMessage.text = ""
        }
    }
    
    private func setColor() {
        switch style {
        case .Success:
            self.view.backgroundColor = UIColor(red: 26.0/255.0, green: 128.0/255.0, blue: 60.0/255.0, alpha: 1)
            self.view.alpha = 1
        case .Warning:
            self.view.backgroundColor = UIColor(red: 229.0/255.0, green: 153.0/255.0, blue: 0, alpha: 1)
            self.view.alpha = 1
        case .Error:
            self.view.backgroundColor = UIColor(red: 153.0/255.0, green: 15.0/255.0, blue: 15.0/255.0, alpha: 1)
            self.view.alpha = 1
        case .Infor:
            self.view.backgroundColor = UIColor(red: 0, green: 190.0/255.0, blue: 230.0/255.0, alpha: 1)
            self.view.alpha = 1
        default:
            self.view.backgroundColor = UIColor.lightGrayColor()
            self.view.alpha = 0
        }
    }
    
    private func doAnimation() {
        if style == .Hidden {
            if (isShowing) {
                actionAfterHiding = .None
                hide()
            }
        }
        else if style == .Success {
            showThenHide(successMessage)
        }
        else if style == .Warning {
            if (!isShowing) {
                show(warningMessage)
            }
        }
        else if style == .Error {
            if (!isShowing) {
                show(errorMessage)
            }
        }
    }
    
    private func hide() {
        if (!isShowing) {
            return
        }
        
        self.view.alpha = 0
        
        let rotate = CABasicAnimation(keyPath: "transform.rotation.x")
        rotate.fromValue = 0
        rotate.toValue = M_PI/2
        rotate.duration = animationDuration
        rotate.beginTime = 0.0;
        
        let fadeOut = CABasicAnimation(keyPath: "opacity")
        fadeOut.fromValue = 1.0
        fadeOut.toValue = 0.0
        fadeOut.duration = animationDuration
        fadeOut.beginTime = 0.0
        
        let group = CAAnimationGroup()
        group.animations = [rotate, fadeOut]
        group.duration = animationDuration
        group.delegate = self
        
        group.removedOnCompletion = false
        self.view.layer.addAnimation(group, forKey: "hide")
    }
    
    private func show(msg: String) {
        if (isShowing) {
            actionAfterHiding = .Show
            messageToShowAfterHiding = msg
            hide()
            return
        }
        
        lbMessage.text = msg
        setColor()
        self.view.alpha = 1
        
        let fadeIn = CABasicAnimation(keyPath: "opacity")
        fadeIn.fromValue = 0.0
        fadeIn.toValue = 1.0
        fadeIn.duration = animationDuration
        fadeIn.beginTime = 0.0
        
        let rotate = CABasicAnimation(keyPath: "transform.rotation.x")
        rotate.fromValue = 3*M_PI/2
        rotate.toValue = 2*M_PI
        rotate.duration = animationDuration
        rotate.beginTime = 0.0
        
        let group = CAAnimationGroup()
        group.animations = [fadeIn,rotate]
        group.duration = animationDuration
        group.delegate = self
        
        group.removedOnCompletion = false
        self.view.layer.addAnimation(group, forKey: "show")
    }
    
    private func showThenHide(msg: String) {
        if (isShowing) {
            actionAfterHiding = .ShowThenHide
            messageToShowAfterHiding = msg
            hide()
            return
        }
        
        lbMessage.text = msg
        setColor()
        self.view.alpha = 1
        
        let fadeIn = CABasicAnimation(keyPath: "opacity")
        fadeIn.fromValue = 0.0
        fadeIn.toValue = 1.0
        fadeIn.duration = animationDuration
        fadeIn.beginTime = 0.0
        
        let rotate1 = CABasicAnimation(keyPath: "transform.rotation.x")
        rotate1.fromValue = 3*M_PI/2
        rotate1.toValue = 2*M_PI
        rotate1.duration = animationDuration
        rotate1.beginTime = 0.0
        
        let group = CAAnimationGroup()
        
        group.animations = [fadeIn, rotate1]
        group.duration = animationDuration + animationPause
        group.delegate = self
        
        group.removedOnCompletion = false
        self.view.layer.addAnimation(group, forKey: "showThenHide")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if (anim == self.view.layer.animationForKey("hide")) {
            self.view.layer.removeAllAnimations()
            self.view.alpha = 0
            isShowing = false
            if (actionAfterHiding != .None) {
                if (actionAfterHiding == .Show) {
                    show(messageToShowAfterHiding)
                }
                else if (actionAfterHiding == .ShowThenHide) {
                    showThenHide(messageToShowAfterHiding)
                }
            }
        }
        else if (anim == self.view.layer.animationForKey("show")) {
            self.view.layer.removeAllAnimations()
            isShowing = true
            self.view.alpha = 1
        }
        else if (anim == self.view.layer.animationForKey("showThenHide")) {
            self.view.layer.removeAllAnimations()
            isShowing = true
            actionAfterHiding = .None
            hide()
        }
    }
}