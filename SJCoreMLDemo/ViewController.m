//
//  ViewController.m
//  SJCoreMLDemo
//
//  Created by Soldier on 2017/8/23.
//  Copyright © 2017年 Shaojie Hong. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Extension.h"
#import <CoreML/CoreML.h>
#import "Resnet50.h"
#import <Vision/Vision.h>

#define kGrayColor RGBCOLOR(60, 60, 60)

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UIImagePickerController *imagePickController;

@end




@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kGrayColor;
    
    [self constructView];
}

- (void)constructView {
    self.resultLabel.frame = CGRectMake(20, 50, self.view.width - 20 * 2, 30);
    
    [self imageView];
    
    UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    checkBtn.frame = CGRectMake(20, self.view.height - 30 - 45, self.view.width - 20 * 2, 45);
    [checkBtn addTarget:self action:@selector(startRecognitionAction:) forControlEvents:UIControlEventTouchUpInside];
    [checkBtn setBackgroundColor:[UIColor whiteColor]];
    checkBtn.clipsToBounds = YES;
    checkBtn.layer.cornerRadius = 4;
    [checkBtn setTitle:@"识别图片" forState:UIControlStateNormal];
    [checkBtn setTitleColor:kGrayColor forState:UIControlStateNormal];
    checkBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:checkBtn];
    
    UIButton *selectImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectImgBtn.frame = CGRectMake(20, checkBtn.top - 20 - 45, self.view.width - 20 * 2, 45);
    [selectImgBtn addTarget:self action:@selector(selectImageAction:) forControlEvents:UIControlEventTouchUpInside];
    [selectImgBtn setBackgroundColor:[UIColor whiteColor]];
    selectImgBtn.clipsToBounds = YES;
    selectImgBtn.layer.cornerRadius = 4;
    [selectImgBtn setTitle:@"选择图片" forState:UIControlStateNormal];
    [selectImgBtn setTitleColor:kGrayColor forState:UIControlStateNormal];
    selectImgBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:selectImgBtn];
}

- (void)startRecognitionAction:(UIButton *)sender {
    UIImage *image = self.imageView.image;
    
    Resnet50 *resnetModel = [[Resnet50 alloc] init];
    VNCoreMLModel *vnCoreModel = [VNCoreMLModel modelForMLModel:resnetModel.model error:nil];
    
    __weak typeof(self) weakSelf = self;
    VNCoreMLRequest *vnCoreMlRequest = [[VNCoreMLRequest alloc] initWithModel:vnCoreModel completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        CGFloat confidence = 0.0f; //识别率,值越高应该是越接近的
        VNClassificationObservation *tempClassification = nil;
        //VNClassificationObservation 对分析结果的一种描述类
        for (VNClassificationObservation *classification in request.results) {
            if (classification.confidence > confidence) {
                confidence = classification.confidence;
                tempClassification = classification;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [NSString stringWithFormat:@"%@ (%.0f%%)", [[tempClassification.identifier componentsSeparatedByString:@", "] firstObject], tempClassification.confidence * 100];
            weakSelf.resultLabel.text = result;
        });
    }];
    
    VNImageRequestHandler *vnImageRequestHandler = [[VNImageRequestHandler alloc] initWithCGImage:image.CGImage options:nil];
    
    NSError *error = nil;
    [vnImageRequestHandler performRequests:@[vnCoreMlRequest] error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
}

- (void)selectImageAction:(UIButton *)sender {
    [self presentViewController:self.imagePickController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *selectImage = [info objectForKey:UIImagePickerControllerEditedImage];
    self.imageView.image = selectImage;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImagePickerController *)imagePickController {
    if (!_imagePickController) {
        _imagePickController = [[UIImagePickerController alloc] init];
        _imagePickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePickController.delegate = self;
        _imagePickController.allowsEditing = YES;
    }
    return _imagePickController;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 120, self.view.width - 20 * 2, 350)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.layer.cornerRadius = 4;
        [self.view addSubview:_imageView];
    }
    return _imageView;
}

- (UILabel *)resultLabel {
    if (!_resultLabel) {
        _resultLabel = [[UILabel alloc] init];
        _resultLabel.textAlignment = NSTextAlignmentCenter;
        _resultLabel.font = [UIFont boldSystemFontOfSize:22];
        _resultLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:_resultLabel];
    }
    return _resultLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
