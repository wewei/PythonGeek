//
//  PGMainViewController.m
//  PythonGeek
//
//  Created by Wei Wei on 11/30/12.
//  Copyright (c) 2012 Wei Wei. All rights reserved.
//

#import "PGMainViewController.h"
#import "PGPythonRuntime.h"

@interface PGMainViewController ()

@end

@implementation PGMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.scriptTextBox.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.scriptTextBox.autocorrectionType = UITextAutocorrectionTypeNo;

    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationStdoutWritten
                                                      object:[PGPythonRuntime sharedRuntime]
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      NSString *text = [note.userInfo objectForKey:kUserInfoKeyText];
                                                      [self appendTextToStdout:text];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationStderrWritten
                                                      object:[PGPythonRuntime sharedRuntime]
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      NSString *text = [note.userInfo objectForKey:kUserInfoKeyText];
                                                      [self appendTextToStderr:text];
                                                  }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_scriptTextBox release];
    [_stdoutTextBox release];
    [_stderrTextBox release];
    [super dealloc];
}

- (void)appendTextToStdout:(NSString *)text {
    self.stdoutTextBox.text = [self.stdoutTextBox.text stringByAppendingString:text];
}

- (void)appendTextToStderr:(NSString *)text {
    self.stderrTextBox.text = [self.stderrTextBox.text stringByAppendingString:text];
}


- (IBAction)clearOutput:(id)sender {
    self.stdoutTextBox.text = @"";
    self.stderrTextBox.text = @"";
}

- (IBAction)executeScript:(id)sender {
    [[PGPythonRuntime sharedRuntime] performSelectorInBackground:@selector(executeScriptString:)
                                                      withObject:self.scriptTextBox.text];
    [self.scriptTextBox resignFirstResponder];
}
@end
