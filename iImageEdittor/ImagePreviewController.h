//
//  ImagePreviewController.h
//  CameraApp
//
//  Created by Rajesh on 3/7/15.
//

#import <UIKit/UIKit.h>

typedef enum{
    CropShapeRect = 0,
    CropShapeOval
}CropShape;

struct ImageCropingAttributes {
    CropShape shape;
    float widthFactor;
    float heightFactor;
};

@interface ImagePreviewController : UIViewController<UIScrollViewDelegate>
{
    UIScrollView *scrollView;
    UIImageView *imageView;
    CGRect cropRect;
}
@property(nonatomic,strong)UIImage *image;
@property(nonatomic,assign)struct ImageCropingAttributes attributes;
@property(nonatomic,assign)id delegate;
@end
