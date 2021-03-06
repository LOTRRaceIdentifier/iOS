//
//  ViewController.m
//  LOTRFaceRecognition
//
//  Created by Manas Purohit on 10/9/16.
//  Copyright © 2016 Manas Purohit. All rights reserved.
//

#import "ViewController.h"
#import "ClarifaiApp.h"
#import "ImageViewController.h"

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *picButton;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UILabel *recLabel;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (strong, nonatomic) ClarifaiApp *app;
@end

@implementation ViewController


- (IBAction)picButtonPressed:(id)sender {
    
}

- (IBAction)imageButtonPressed:(id)sender {
    // Show a UIImagePickerController to let the user pick an image from their library.
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = NO;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        // The user picked an image. Send it to Clarifai for recognition.
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.image = image;
        self.recLabel.hidden = NO;
        self.orLabel.hidden = YES;
        self.picButton.hidden = YES;
        self.imageButton.hidden = YES;
        self.picButton.enabled = NO;
        self.imageButton.enabled = NO;
        [self recognizeImage:image];
    }
}

- (void)recognizeImage:(UIImage *)image {
    
    // Initialize the Clarifai app with your app's ID and Secret.
    ClarifaiApp *app = [[ClarifaiApp alloc] initWithAppID:@"6S7FPXvrIVyCJ1XCZAFpCYiP0kPuYh2mQ7nKI_V2"
                                                appSecret:@"iVvFW68YjI67carFjoO90dlKJfS47ptTpOPzZ0-V"];
    
    // Fetch Clarifai's general model.
    [app getModelByName:@"general-v1.3" completion:^(ClarifaiModel *model, NSError *error) {
        // Create a Clarifai image from a UIImage.
        ClarifaiImage *clarifaiImage = [[ClarifaiImage alloc] initWithImage:image];
        
        // Use Clarifai's general model to pedict tags for the given image.
        [model predictOnImages:@[clarifaiImage] completion:^(NSArray<ClarifaiOutput *> *outputs, NSError *error) {
            if (!error) {
                ClarifaiOutput *output = outputs[0];
                
                bool grey = false;
                bool beard = false;
                bool manOrAdult = false;
                bool longH = false;
                bool hair = false;
                bool crown = false;
                
                for (ClarifaiConcept *concept in output.concepts) {
                    if ([concept.conceptName isEqualToString:@"grey"]) {
                        grey = true;
                    }
                    if ([concept.conceptName isEqualToString:@"beard"]) {
                        beard = true;
                    }
                    if ([concept.conceptName isEqualToString:@"man"] || [concept.conceptName isEqualToString:@"adult"]) {
                        manOrAdult = true;
                    }
                    if ([concept.conceptName isEqualToString:@"hair"]) {
                        hair = true;
                    }
                    if ([concept.conceptName isEqualToString:@"long"]) {
                        longH = true;
                    }
                    if ([concept.conceptName isEqualToString:@"crown"]) {
                        crown = true;
                    }
                }
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    ImageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ImageViewController"];
                    
                    if (beard) {
                        if (grey) {
                            vc.image = [UIImage imageNamed:@"Images/gandalf.jpg"];
                            vc.string = @"You are Gandalf!";
                        }
                        else {
                            vc.image = [UIImage imageNamed:@"Images/gimli.jpg"];
                            vc.string = @"You are a Dwarf!";
                        }
                    }
                    else if (crown) {
                        vc.image = [UIImage imageNamed:@"Images/galadriel.jpg"];
                        vc.string = @"You are Galadriel!";
                    }
                    else if (manOrAdult) {
                        vc.image = [UIImage imageNamed:@"Images/man.jpg"];
                        vc.string = @"You are a Human!";
                    }
                    else if (longH && hair) {
                        vc.image = [UIImage imageNamed:@"Images/elf.jpg"];
                        vc.string = @"You are an Elf!";
                    }
                    else {
                        vc.image = [UIImage imageNamed:@"Images/goblin.jpg"];
                        vc.string = @"Trying to fool me, Goblin?";
                    }
                    
                    [self presentViewController:vc animated:YES completion:nil];
                });
            }
        }];
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.recLabel.hidden = YES;
    self.orLabel.hidden = NO;
    self.picButton.hidden = NO;
    self.imageButton.hidden = NO;
    self.picButton.enabled = YES;
    self.imageButton.enabled = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
