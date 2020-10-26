//
//  NSObject+KVC.h
//  KVC
//
//  Created by UED on 2020/10/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KVC)

- (void)customSetValue:(id)value forKey:(NSString *)key;

- (id)customValueForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
