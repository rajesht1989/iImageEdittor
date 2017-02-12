//
//  ViewController.m
//  CameraApp
//
//  Created by Rajesh on 3/7/15.
//

#import "ViewController.h"
#import "ImagePreviewController.h"

@interface ViewController () {
    UIImagePickerController *picker;
    UIImage *imageSelected;
    struct ImageCropingAttributes attributes;
    IBOutlet UIImageView *imageVw;
    IBOutlet UIButton *hideButton;
    IBOutlet UIView *bgView;
    IBOutlet UILabel *heightLabel;
    IBOutlet UILabel *widthLabel;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPhotoCaptured) name:@"_UIImagePickerControllerUserDidCaptureItem" object:nil];
    attributes.heightFactor = 1;
    attributes.widthFactor = 1;
    attributes.shape = CropShapeRect;
}

- (IBAction)hideAction:(id)sender {
    [hideButton setHidden:YES];
    [imageVw setImage:[UIImage imageNamed:@"Launch icon"]];
}

- (IBAction)sliderAction:(UISlider *)sender {
    if (sender.tag == 1) {
        [heightLabel setText:[NSString stringWithFormat:@"Height = %.1f",sender.value]];
        attributes.heightFactor = sender.value;
    } else {
        [widthLabel setText:[NSString stringWithFormat:@"Width = %.1f",sender.value]];
        attributes.widthFactor = sender.value;
    }
}

- (IBAction)switchAction:(UISwitch *)sender {
    if (sender.isOn) {
        attributes.shape = CropShapeOval;
    } else {
        attributes.shape = CropShapeRect;
    }
}

- (IBAction)cameraTapped:(id)sender {
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:nil];
}
- (IBAction)albumTapped:(id)sender {
    [picker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)pickerLocal didFinishPickingMediaWithInfo:(NSDictionary *)info {
    imageSelected = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (imageSelected) {
        [picker dismissViewControllerAnimated:YES completion:^{
            ImagePreviewController *imagePreView = [[ImagePreviewController alloc] init];
            [imagePreView setImage:imageSelected];
            [imagePreView setAttributes:attributes];
            [imagePreView setImageCompletion:^(UIImage *image) {
                [hideButton setHidden:NO];
                [imageVw setImage:image];
            }];
            [self presentViewController:imagePreView animated:YES completion:nil];
        }];
    }
}

- (void)loadPhotoCaptured {
    UIImage *img = (UIImage *)[[[self allImageViewsSubViews:[[[picker viewControllers]firstObject] view]] lastObject] image];
    if (img) {
        UIImagePickerController *imagePicker;
        [self imagePickerController:imagePicker didFinishPickingMediaWithInfo:[NSDictionary dictionaryWithObject:img forKey:UIImagePickerControllerOriginalImage]];
    } else {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSMutableArray*)allImageViewsSubViews:(UIView *)view {
    NSMutableArray *arrImageViews=[NSMutableArray array];
    if ([view isKindOfClass:[UIImageView class]]) {
        [arrImageViews addObject:view];
    } else {
        for (UIView *subview in [view subviews]) {
            [arrImageViews addObjectsFromArray:[self allImageViewsSubViews:subview]];
        }
    }
    return arrImageViews;
}

@end
