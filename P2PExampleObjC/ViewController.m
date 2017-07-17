//
//  ViewController.m
//  P2PExampleObjC
//
//  Created by Vitaliy Kuzmenko on 17/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

@import P2PCore;

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [P2PCore setWithPartnerId:@"hello"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
