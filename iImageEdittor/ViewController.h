//
//  ViewController.h
//  CameraApp
//
//  Created by Rajesh on 3/7/15.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (void)croppedImage:(UIImage *)image;

@end

