//
//  ViewPhoto.swift
//  Photos Gallery App
//
//  Created by Tony on 7/7/14.
//  Copyright (c) 2014 Abbouds Corner. All rights reserved.
//
//  Updated for Xcode 6.0.1 GM 

import UIKit
import Photos

class ViewPhoto: UIViewController, UIActionSheetDelegate {
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult!
    var index: Int = 0
    
    // Gesture paramers
    var lastScaleFactor: CGFloat! = 1 // Enlarge or redcue
    var netRotation: CGFloat = 1 // Rotation
    var netTranslation : CGPoint! // Translations
    
    
    //@Return to photos
    @IBAction func btnCancel(sender : AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true) //!!Added Optional Chaining
    }
    
    //@Export photo
    @IBAction func btnExport(sender : AnyObject) {
        println("Export")
    }
    
    //@Remove photo from Collection
    @IBAction func btnTrash(sender : AnyObject) {
        let alert = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this image?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default,
            handler: {(alertAction)in
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    //Delete Photo
                    let request = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
                    request.removeAssets([self.photosAsset[self.index]])
                    },
                    completionHandler: {(success, error)in
                        NSLog("\nDeleted Image -> %@", (success ? "Success":"Error!"))
                        alert.dismissViewControllerAnimated(true, completion: nil)
                        if(success){
                            // Move to the main thread to execute
                            dispatch_async(dispatch_get_main_queue(), {
                                self.photosAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
                                if(self.photosAsset.count == 0){
                                    println("No Images Left!!")
                                    self.navigationController?.popToRootViewControllerAnimated(true)
                                }else{
                                    if(self.index >= self.photosAsset.count){
                                        self.index = self.photosAsset.count - 1
                                    }
                                    self.displayPhoto()
                                }
                            })
                        }else{
                            println("Error: \(error)")
                        }
                })
            }))
        
        alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: {(alertAction)in
            //Do not delete photo
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBOutlet var imgView : UIImageView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Tap Gesture
        var tapGesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        tapGesture.numberOfTapsRequired = 2 // Double-click : 2
        self.view.addGestureRecognizer(tapGesture)
        
        // Swipe gesture
        // Swipe right
        var swipeRightGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        self.view.addGestureRecognizer(swipeRightGesture)
        
        // Swipe left
        var swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        swipeLeftGesture.direction = UISwipeGestureRecognizerDirection.Left // Default is right
        self.view.addGestureRecognizer(swipeLeftGesture)
        
        // Pinch gesture
        var pinchGesture = UIPinchGestureRecognizer(target: self, action: "handlePinchGesture:")
        self.view.addGestureRecognizer(pinchGesture)
    }
    
    // Handle tap gesture
    func handleTapGesture(gesture: UITapGestureRecognizer){
        if imgView.contentMode == UIViewContentMode.ScaleAspectFit{
            imgView.contentMode = UIViewContentMode.Center
        }else{
            imgView.contentMode = UIViewContentMode.ScaleAspectFit
        }
    }
    
    // Handle swipe gesture
    func handleSwipeGesture(gesture: UISwipeGestureRecognizer){
        
        var direction = gesture.direction
        
        println("\(direction)")
        
        switch direction {
        case UISwipeGestureRecognizerDirection.Left:
            // Left
            if self.index == self.photosAsset.count - 1 {
                self.index = 0
            }else {
                self.index++
            }

        case UISwipeGestureRecognizerDirection.Right:
            // Right
            if self.index == 0 {
                self.index = self.photosAsset.count - 1
            }else{
                self.index--
            }
        default:
            break
        }
        // Display the photo
        self.displayPhoto()
    }
    
    // Handle pinch gesture -- enlarge or reduce the size of images
    func handlePinchGesture(sender: UIPinchGestureRecognizer){
        var factor = sender.scale
        if factor > 1 {
            // Enlarge
            imgView.transform = CGAffineTransformMakeScale(lastScaleFactor + factor - 1, lastScaleFactor + factor - 1)
        } else {
            // Reduce
            imgView.transform = CGAffineTransformMakeScale(lastScaleFactor * factor, lastScaleFactor * factor)
        }
        
        // juige the state of image view to save the data
        if sender.state == UIGestureRecognizerState.Ended {
            if factor > 1 {
                lastScaleFactor = lastScaleFactor + factor - 1
            } else {
                lastScaleFactor = lastScaleFactor * factor
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.hidesBarsOnTap = true    //!!Added Optional Chaining
        
        self.displayPhoto()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func displayPhoto(){
        // Set targetSize of image to iPhone screen size
        let screenSize: CGSize = UIScreen.mainScreen().bounds.size
        let targetSize = CGSizeMake(screenSize.width, screenSize.height)

        let imageManager = PHImageManager.defaultManager()
        if let asset = self.photosAsset[self.index] as? PHAsset{
            var ID = imageManager.requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFit, options: nil, resultHandler: {
                (result, info)->Void in
                    self.imgView.image = result
            })
        }
    }



}
