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

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *resultRateLabel;
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UIImagePickerController *imagePickController;

@end




@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self constructView];
}

- (void)constructView {
    UIButton *selectImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectImgBtn.frame = CGRectMake(self.view.width * 0.5 - 20 - 90, self.imageView.bottom + 30, 90, 3);
    [selectImgBtn addTarget:self action:@selector(selectImageAction:) forControlEvents:UIControlEventTouchUpInside];
    selectImgBtn.clipsToBounds = YES;
    selectImgBtn.layer.cornerRadius = 16;
    selectImgBtn.layer.borderWidth = 1;
    selectImgBtn.layer.borderColor = [UIColor orangeColor].CGColor;
    [selectImgBtn setTitle:@"选择图片" forState:UIControlStateNormal];
    [selectImgBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    selectImgBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:selectImgBtn];
    
    UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    checkBtn.frame = CGRectMake(self.view.width * 0.5 + 20, self.imageView.bottom + 30, 90, 32);
    [checkBtn addTarget:self action:@selector(startRecognitionAction:) forControlEvents:UIControlEventTouchUpInside];
    checkBtn.clipsToBounds = YES;
    checkBtn.layer.cornerRadius = 15;
    checkBtn.layer.borderWidth = 1;
    checkBtn.layer.borderColor = [UIColor orangeColor].CGColor;
    [checkBtn setTitle:@"识别图片" forState:UIControlStateNormal];
    [checkBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    checkBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:checkBtn];
    
    self.resultLabel.frame = CGRectMake(16, checkBtn.bottom + 35, self.view.width - 16 * 2, 20);
    
    self.resultRateLabel.frame = CGRectMake(16, self.resultLabel.bottom + 20, self.view.width - 16 * 2, 20);
}

- (void)startRecognitionAction:(UIButton *)sender {
    UIImage *image = self.imageView.image;
    
    Resnet50 *resnetModel = [[Resnet50 alloc] init];
    VNCoreMLModel *vnCoreModel = [VNCoreMLModel modelForMLModel:resnetModel.model error:nil];
    
    __weak typeof(self) weakSelf = self;
    VNCoreMLRequest *vnCoreMlRequest = [[VNCoreMLRequest alloc] initWithModel:vnCoreModel completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        CGFloat confidence = 0.0f;
        VNClassificationObservation *tempClassification = nil;
        for (VNClassificationObservation *classification in request.results) {
            if (classification.confidence > confidence) {
                confidence = classification.confidence;
                tempClassification = classification;
            }
        }
        
        weakSelf.resultLabel.text = tempClassification.identifier;
        weakSelf.resultRateLabel.text = [NSString stringWithFormat:@"匹配率:%@", @(tempClassification.confidence)];
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
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 30, self.view.width - 16 * 2, 350)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.layer.cornerRadius = 6;
        _imageView.layer.borderColor = [UIColor orangeColor].CGColor;
        _imageView.layer.borderWidth = 1;
        [self.view addSubview:_imageView];
    }
    return _imageView;
}

- (UILabel *)resultLabel {
    if (!_resultLabel) {
        _resultLabel = [[UILabel alloc] init];
        _resultLabel.textAlignment = NSTextAlignmentCenter;
        _resultLabel.font = [UIFont systemFontOfSize:17];
        _resultLabel.textColor = [UIColor orangeColor];
        [self.view addSubview:_resultLabel];
    }
    return _resultLabel;
}

- (UILabel *)resultRateLabel {
    if (!_resultRateLabel) {
        _resultRateLabel = [[UILabel alloc] init];
        _resultRateLabel.textAlignment = NSTextAlignmentCenter;
        _resultRateLabel.font = [UIFont systemFontOfSize:14];
        _resultRateLabel.textColor = [UIColor orangeColor];
        [self.view addSubview:_resultRateLabel];
    }
    return _resultRateLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
