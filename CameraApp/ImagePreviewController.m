//
//  ImagePreviewController.m
//  CameraApp
//
//  Created by Rajesh on 3/7/15.
//

#import "ImagePreviewController.h"
#import "ViewController.h"

@interface ImagePreviewController()
{
    UIBezierPath *cropBeziarPath;
}
@property (nonatomic, readonly) UIImageView *transparentMaskView;
@end

@implementation ImagePreviewController
@synthesize transparentMaskView= _transparentMaskView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self applyCropWithWidth:self.attributes.widthFactor andHeight:self.attributes.heightFactor];
}
-(void) applyCropWithWidth:(CGFloat) widthFactor andHeight:(CGFloat) heightFactor
{
    CGRect imageRect = self.view.bounds;
    CGFloat fSmallerSide = imageRect.size.width < imageRect.size.height ? imageRect.size.width : imageRect.size.height;
    if (widthFactor>=heightFactor)
    {
        cropRect = CGRectMake(0,(imageRect.size.height - (heightFactor*imageRect.size.width/widthFactor))/2.0f ,imageRect.size.width,heightFactor*imageRect.size.width/widthFactor );
    }
    else
    {
        cropRect = CGRectMake((imageRect.size.width - (imageRect.size.height*widthFactor/heightFactor))/2.0f,0,imageRect.size.height*widthFactor/heightFactor,imageRect.size.height );
        
    }
    imageRect = cropRect;
    CGFloat aspectRatio = self.image.size.width / self.image.size.height;
    CGFloat zoomScale;

    if (aspectRatio > 1)//Landscape Image
    {
        imageRect.size.width = fSmallerSide*aspectRatio;
        imageRect.size.height = fSmallerSide;
        zoomScale = cropRect.size.height / imageRect.size.height;
    }
    else
    {
        imageRect.size.width = fSmallerSide;
        imageRect.size.height = fSmallerSide/aspectRatio;
        zoomScale = imageRect.size.width/cropRect.size.width;
    }
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [scrollView setClipsToBounds:NO];
    [scrollView setBounces:YES];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setMinimumZoomScale:1];
    [scrollView setMaximumZoomScale:100];
    [scrollView setDelegate:self];
    [scrollView setContentInset:UIEdgeInsetsMake(imageRect.origin.y, imageRect.origin.x, scrollView.bounds.size.height - cropRect.size.height - imageRect.origin.y, scrollView.bounds.size.width - cropRect.size.width - cropRect.origin.x)];
    [self.view addSubview:scrollView];
    
    imageView = [[UIImageView alloc] initWithImage:self.image];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setFrame:CGRectMake(0, 0, imageRect.size.width, imageRect.size.height)];
    [scrollView addSubview:imageView];
    
    [self.view insertSubview:[self transparentMaskView] aboveSubview:scrollView];
    
    [scrollView setZoomScale:zoomScale];
    [scrollView setMinimumZoomScale:zoomScale];
    [scrollView setMaximumZoomScale:zoomScale*2];
    
    UIView *bottombuttonView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40)];
    [bottombuttonView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [bottombuttonView setTag:1234];
    [self.view addSubview:bottombuttonView];
    
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 60, 40)];
    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancelTapped) forControlEvents:UIControlEventTouchUpInside];
    [bottombuttonView addSubview:cancel];
    UIButton *done = [[UIButton alloc] initWithFrame:CGRectMake(bottombuttonView.bounds.size.width - 60 - 10, 0, 60, 40)];
    [done setTitle:@"Done" forState:UIControlStateNormal];
    [done addTarget:self action:@selector(doneTapped) forControlEvents:UIControlEventTouchUpInside];
    [bottombuttonView addSubview:done];

}

- (UIImageView *)transparentMaskView
{
    if (!_transparentMaskView)
    {
        _transparentMaskView = [[UIImageView alloc] initWithImage:[self transparentImage]];
        _transparentMaskView.userInteractionEnabled = NO;
    }
    return _transparentMaskView;
}

- (UIImage *)transparentImage
{
    CGRect bounds = self.view.bounds;
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0.f);
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:bounds];
    if (self.attributes.shape == CropShapeRect)
    {
        cropBeziarPath = [UIBezierPath bezierPathWithRect:cropRect];
    }
    else
    {
        cropBeziarPath = [UIBezierPath bezierPathWithOvalInRect:cropRect];
    }

    [clipPath appendPath:cropBeziarPath];
    clipPath.usesEvenOddFillRule = YES;
    [[UIColor colorWithWhite:0 alpha:0.5] setFill];
    [clipPath fill];
    
    cropBeziarPath.lineWidth = .5;
    //set the stoke color
    [[UIColor whiteColor] setStroke];
    //draw the path
    [cropBeziarPath stroke];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
- (UIImage *)getimageInRect:(CGRect)visibleRect
{
    UIGraphicsBeginImageContext(visibleRect.size);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), visibleRect.origin.x,
                          visibleRect.origin.y);
    [self.view.layer
     renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}



- (void)cancelTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)doneTapped
{
    [[self.view viewWithTag:1234]removeFromSuperview];
    [(ViewController *)self.delegate croppedImage:[self croppedImage:[ImagePreviewController imageWithView:self.view]]];
    [self dismissViewControllerAnimated:YES completion:nil];
}


+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (UIImage *)croppedImage:(UIImage *)image

{
    
    [cropBeziarPath closePath];
    
    // Load image thumbnail
    CGSize imageSize = image.size;
    CGRect imageRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [[UIScreen mainScreen] scale]);
    
    // Create the clipping path and add it
    [cropBeziarPath addClip];
    [image drawInRect:imageRect];
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return croppedImage;
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}
@end


