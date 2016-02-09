//
//  ViewController.swift
//  translate_ios
//
//  Created by Thuy Duong on 04/10/15.
//  Copyright © 2015 PiscesTeam. All rights reserved.
//

import UIKit
import AVFoundation

enum TranslateError: ErrorType {
    case InvalidSelection
    case InsufficientFunds(coinsNeeded: Int)
    case OutOfStock
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var btnCapture: UIButton!
    @IBOutlet weak var btnPhotoLibrary: UIButton!

    let captureSession = AVCaptureSession()
    var viewportLayer: AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
    var viewportView: UIView!
    var camFocus: CameraFocusSquare!
    var resultImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        
        if captureDevice != nil {
            do {
                try beginSession()
            }
            catch {
                print("Error...")
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func beginSession() throws {
        try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        viewportLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        let screenSize:CGRect = UIScreen.mainScreen().bounds
        viewportLayer?.frame = CGRectMake(0, 0, screenSize.width, screenSize.width*4/3)

        viewportView = UIView(frame: viewportLayer!.frame)
        viewportView.layer.addSublayer(viewportLayer!)
        view.addSubview(viewportView)
        
        view.bringSubviewToFront(btnPhotoLibrary)
        view.bringSubviewToFront(btnCapture)

        captureSession.startRunning()
        try configureDevice()
    }
    
    func configureDevice() throws {
        if let device = captureDevice {
            try device.lockForConfiguration()
            device.focusMode = .AutoFocus
            device.unlockForConfiguration()
        }
    }
    
    @available(iOS 8.0, *)
    func focusTo(value : Float) throws {
        if let device = captureDevice {
            //try device.lockForConfiguration()
            device.setFocusModeLockedWithLensPosition(value, completionHandler: {(time) -> Void in})
            //device.unlockForConfiguration()
        }
    }
    
    func showCameraFocus(touchPoint: CGPoint) {
        if camFocus != nil {
            camFocus.removeFromSuperview()
        }
        
        camFocus = CameraFocusSquare(frame: CGRectMake(touchPoint.x - 30, touchPoint.y - 30, 60, 60))
        camFocus.backgroundColor = UIColor.clearColor()
        viewportView.addSubview(camFocus)
        camFocus.setNeedsDisplay()
    }

    func doTouch(touches: Set<UITouch>) {
        let anyTouch = (touches.first as UITouch!).locationInView(viewportView)
        showCameraFocus(anyTouch)
//        let touchPercent = anyTouch.x / screenWidth
        
        //        if #available(iOS 8.0, *) {
        //            do {
        //                try focusTo(Float(touchPercent))
        //            }
        //            catch {
        //                print("Error when focus...")
        //            }
        //        }
        //        else {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
            }
            catch {
                return
            }
            
            let touchPoint = CGPointMake(anyTouch.x/viewportView.frame.size.width, anyTouch.y/viewportView.frame.size.height)
            
            device.focusPointOfInterest = touchPoint
            device.exposurePointOfInterest = touchPoint
            device.focusMode = .AutoFocus
            if (device.isExposureModeSupported(.ContinuousAutoExposure)) {
                device.exposureMode = .ContinuousAutoExposure
            }
            
            device.unlockForConfiguration()
        }
        //        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        doTouch(touches)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        doTouch(touches)
    }

    @IBAction func btnCapturePressed() {
        let stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        captureSession.addOutput(stillImageOutput)
        
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo){
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                (sampleBuffer, error) in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                self.resultImage = UIImage(data: imageData,scale:1.0)
                self.processResultImage()
                UIImageWriteToSavedPhotosAlbum(self.resultImage, nil, nil, nil)
                
            })
        }
    }
    
    @IBAction func btnPhotoLibraryPressed() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .PhotoLibrary
        imagePickerController.allowsEditing = false
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            resultImage = pickedImage
            processResultImage()
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func processResultImage() {
        performSegueWithIdentifier("fromCameraToPreviewSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController
        if (vc .isKindOfClass(PreviewViewController)) {
            let vcc = vc as! PreviewViewController
            vcc.image = resultImage
        }
    }
}

