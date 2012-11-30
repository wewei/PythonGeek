//
//  PGMainViewController.h
//  PythonGeek
//
//  Created by Wei Wei on 11/30/12.
//  Copyright (c) 2012 Wei Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGMainViewController : UIViewController
@property (retain, nonatomic) IBOutlet UITextView *scriptTextBox;
@property (retain, nonatomic) IBOutlet UITextView *stdoutTextBox;
@property (retain, nonatomic) IBOutlet UITextView *stderrTextBox;

- (IBAction)clearOutput:(id)sender;
- (IBAction)executeScript:(id)sender;

@end
