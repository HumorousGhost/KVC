//
//  Person.h
//  KVC
//
//  Created by qihoo on 2022/8/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject {
    NSString *_sex;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int age;

@end

NS_ASSUME_NONNULL_END
