//
//  ViewController.m
//  CameraApp
//
//  Created by Rajesh on 3/7/15.
//

#import "ViewController.h"
#import "ImagePreviewController.h"

@interface ViewController ()
{
    UIImagePickerController *picker;
    UIImage *imageSelected;
    struct ImageCropingAttributes attributes;
    UIImageView *imageVw;
    UIButton *hideButton;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPhotoCaptured) name:@"_UIImagePickerControllerUserDidCaptureItem" object:nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    attributes.shape = CropShapeRect;
    attributes.heightFactor=1.0f;
    attributes.widthFactor = 1.0f;
    
    imageVw = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [imageVw setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:imageVw];
    
    UILabel *leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 90, 100, 50)];
    [leftLabel setTextColor:[UIColor redColor]];
    [leftLabel setText:@"Rect"];
    [self.view addSubview:leftLabel];
    
    UISwitch *shapeSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(130, 100, 50, 50)];
    [shapeSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:shapeSwitch];
    
    UILabel *rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(220, 90, 100, 50)];
    [rightLabel setTextColor:[UIColor redColor]];
    [rightLabel setText:@"Oval"];
    [self.view addSubview:rightLabel];
    
    
    UILabel *heightLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 150, 200, 20)];
    [heightLabel setText:@"Height = 1"];
    
    [heightLabel setTextColor:[UIColor redColor]];
    heightLabel.tag = 4;
    [self.view addSubview:heightLabel];
    
    UISlider *heightSlider = [[UISlider alloc]initWithFrame:CGRectMake(80, 150, 150, 100)];
    heightSlider.tag = 1;
    heightSlider.minimumValue = 1.0;
    heightSlider.maximumValue = 5.0;
    [heightSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:heightSlider];
    
    
    UILabel *widthLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 210, 200, 20)];
    widthLabel.tag = 3;
    [widthLabel setTextColor:[UIColor redColor]];
    [widthLabel setText:@"Width = 1"];
    [self.view addSubview:widthLabel];
    
    UISlider *widthSlider = [[UISlider alloc]initWithFrame:CGRectMake(80, 220, 150, 100)];
    widthSlider.minimumValue = 1.0;
    widthSlider.maximumValue = 5.0;
    widthSlider.tag = 2;
    [widthSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:widthSlider];
    
    
    UIButton *cameraButton = [[UIButton alloc]initWithFrame:CGRectMake(10, self.view.frame.size.height-60, 100, 60)];
    [cameraButton setTitle:@"Camera" forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(cameraTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cameraButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:cameraButton];
    
    
     hideButton = [[UIButton alloc]initWithFrame:CGRectMake(cameraButton.frame.size.width+10,  self.view.frame.size.height-60, 100, 60)];
    [hideButton setTitle:@"Hide" forState:UIControlStateNormal];
    [hideButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [hideButton addTarget:self action:@selector(hideAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hideButton];
    [hideButton setHidden:YES];
    
    
    UIButton *galleryButton = [[UIButton alloc]initWithFrame:CGRectMake(200, self.view.frame.size.height-60, 100, 60)];
    [galleryButton setTitle:@"Gallery" forState:UIControlStateNormal];
    [galleryButton addTarget:self action:@selector(albumTapped:) forControlEvents:UIControlEventTouchUpInside];
    [galleryButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:galleryButton];
}
-(void)hideAction:(id) sender
{
    [hideButton setHidden:YES];
     [imageVw setImage:nil];
}
-(void)sliderAction:(UISlider *) sender
{
    if (sender.tag == 1)
    {
        [(UILabel*)[self.view viewWithTag:4] setText:[NSString stringWithFormat:@"Height = %f",sender.value]];
        attributes.heightFactor = sender.value;
    }
    else
    {
        [(UILabel*)[self.view viewWithTag:3] setText:[NSString stringWithFormat:@"Width = %f",sender.value]];
        attributes.widthFactor = sender.value;
    }
}

-(void)switchAction:(UISwitch*)sender
{
    if (sender.isOn)
    {
        attributes.shape = CropShapeOval;
    }
    else
    {
        attributes.shape = CropShapeRect;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)cameraTapped:(id)sender
{
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:nil];
}
- (void)albumTapped:(id)sender
{
    [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)pickerLocal didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    imageSelected = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (imageSelected)
    {
        [picker dismissViewControllerAnimated:YES completion:^{
            ImagePreviewController *imagePreView = [[ImagePreviewController alloc] init];
            [imagePreView setImage:imageSelected];
            [imagePreView setAttributes:attributes];
            [imagePreView setDelegate:self];
            [self presentViewController:imagePreView animated:YES completion:nil];
        }];
    }

}

- (void)loadPhotoCaptured
{
   UIImage *img = [[[self allImageViewsSubViews:[[[picker viewControllers]firstObject] view]] lastObject] image];
    if (img)
    {
        [self imagePickerController:nil didFinishPickingMediaWithInfo:[NSDictionary dictionaryWithObject:img forKey:UIImagePickerControllerOriginalImage]];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)croppedImage:(UIImage *)image
{
    [hideButton setHidden:NO];
    [imageVw setImage:image];
}

- (NSMutableArray*)allImageViewsSubViews:(UIView *)view
{
    NSMutableArray *arrImageViews=[NSMutableArray array];
    if ([view isKindOfClass:[UIImageView class]])
    {
        [arrImageViews addObject:view];
    }
    else
    {
        for (UIView *subview in [view subviews])
        {
            [arrImageViews addObjectsFromArray:[self allImageViewsSubViews:subview]];
        }
    }
    return arrImageViews;
}

@end
