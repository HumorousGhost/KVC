//
//  ViewController.m
//  KVC
//
//  Created by UED on 2020/10/26.
//

#import "ViewController.h"
#import "NSObject+KVC.h"
#import "Person.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    Person *person = [[Person alloc] init];
    [person customSetValue:@"aaa" forKey:@"sex"];
    NSString *name = [person customValueForKey:@"sex"];
    NSLog(@"name = %@", name);
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
