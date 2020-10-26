//
//  NSObject+KVC.m
//  KVC
//
//  Created by UED on 2020/10/26.
//

#import "NSObject+KVC.h"
#import <objc/runtime.h>

@implementation NSObject (KVC)

#pragma mark - Public
- (void)customSetValue:(id)value forKey:(NSString *)key {
    if (!key || key.length == 0) {
        return;
    }
    
    NSString *Key = key.capitalizedString;
    NSString *setKey = [NSString stringWithFormat:@"set%@:", Key];
    NSString *_setKey = [NSString stringWithFormat:@"_set%@:", Key];
    NSString *setIsKey = [NSString stringWithFormat:@"setIs%@:", Key];
    if ([self performSelectorWithMethodName:setKey value:value]) {
        return;
    } else if ([self performSelectorWithMethodName:_setKey value:value]) {
        return;
    } else if ([self performSelectorWithMethodName:setIsKey value:value]) {
        return;
    }
    
    if (![self.class accessInstanceVariablesDirectly]) {
        return [self pushSetterExceptionWithKey:key value:value];
    }
    
    NSArray *array = [self getIverListName];
    NSString *_key = [NSString stringWithFormat:@"_%@", key];
    NSString *_isKey = [NSString stringWithFormat:@"_is%@", Key];
    NSString *isKey = [NSString stringWithFormat:@"is%@", Key];
    if ([array containsObject:_key]) {
        return [self setIvarWithKey:_key value:value];
    } else if ([array containsObject:_isKey]) {
        return [self setIvarWithKey:_isKey value:value];
    } else if ([array containsObject:isKey]) {
        return [self setIvarWithKey:isKey value:value];
    }
    
    [self pushSetterExceptionWithKey:key value:value];
}

- (id)customValueForKey:(NSString *)key {
    if (!key || key.length == 0) {
        return nil;
    }
    
    NSString *Key = key.capitalizedString;
    NSString *getKey = [NSString stringWithFormat:@"get%@", Key];
    NSString *countOfKey = [NSString stringWithFormat:@"countOf%@", Key];
    NSString *objectInKeyAtIndex = [NSString stringWithFormat:@"objectIn%@AtIndex:", Key];
    if ([self respondsToSelector:NSSelectorFromString(getKey)]) {
        return [self performGetterSelectorFormString:getKey];
    } else if ([self respondsToSelector:NSSelectorFromString(key)]) {
        return [self performGetterSelectorFormString:key];
    } else if ([self respondsToSelector:NSSelectorFromString(countOfKey)]) {
        id value = [self performGetterCountOf:countOfKey objectIn:objectInKeyAtIndex];
        if (value) {
            return value;
        }
    }
    
    if (![self.class accessInstanceVariablesDirectly]) {
        return [self pushGetterExceptionWithKey:key];
    }
    
    NSArray *array = [self getIverListName];
    NSString *_key = [NSString stringWithFormat:@"_%@", key];
    NSString *_isKey = [NSString stringWithFormat:@"_is%@", Key];
    NSString *isKey = [NSString stringWithFormat:@"is%@", Key];
    if ([array containsObject:_key]) {
        return [self getIvarWithKey:_key];
    } else if ([array containsObject:_isKey]) {
        return [self getIvarWithKey:_isKey];
    } else if ([array containsObject:key]) {
        return [self getIvarWithKey:key];
    } else if ([array containsObject:isKey]) {
        return [self getIvarWithKey:isKey];
    }
    return [self pushGetterExceptionWithKey:key];
}

#pragma mark - Private
- (BOOL)performSelectorWithMethodName:(NSString *)methodName value:(id)value {
    if ([self respondsToSelector:NSSelectorFromString(methodName)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:NSSelectorFromString(methodName) withObject:value];
#pragma clang diagnostic pop
        return true;
    }
    return false;
}

- (id)performGetterSelectorFormString:(NSString *)key {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id value = [self performSelector:NSSelectorFromString(key)];
#pragma clang diagnostic pop
    return value;
}

- (NSArray *)performGetterCountOf:(NSString *)countOf objectIn:(NSString *)objectIn {
    if ([self respondsToSelector:NSSelectorFromString(objectIn)]) {
        int num = (int)[self performGetterSelectorFormString:countOf];
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < num - 1; i++) {
            num = (int)[self performGetterSelectorFormString:countOf];
        }
        for (int j = 0; j < num; j++) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id objc = [self performSelector:NSSelectorFromString(objectIn) withObject:@(num)];
#pragma clang diagnostic pop
            [array addObject:objc];
        }
        return array;
    }
    return nil;
}

- (void)pushSetterExceptionWithKey:(NSString *)key value:(id)value {
    Method method = class_getInstanceMethod(self.class, NSSelectorFromString(@"setValue:forUndefinedKey:"));
    if (method) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:NSSelectorFromString(@"setValue:forUndefinedKey:") withObject:value withObject:key];
#pragma clang diagnostic pop
        return;
    }
    @throw [NSException exceptionWithName:@"CustomUnknownKeyException" reason:[NSString stringWithFormat:@"[%@ valueForUndefinedKey:]: this class is not key value coding-compliant for the key name.", self] userInfo:nil];
}

- (void)setIvarWithKey:(NSString *)key value:(id)value {
    Ivar ivar = class_getInstanceVariable([self class], key.UTF8String);
    object_setIvar(self, ivar, key);
    return;
}

- (NSArray *)getIverListName {
    NSMutableArray *array = [NSMutableArray array];
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        const char *ivarNameChar = ivar_getName(ivar);
        NSString *ivarName = [NSString stringWithUTF8String:ivarNameChar];
        [array addObject:ivarName];
    }
    free(ivars);
    return [array copy];
}

- (id)pushGetterExceptionWithKey:(NSString *)key {
    Method method = class_getInstanceMethod([self class], NSSelectorFromString(@"valueForUndefinedKey:"));
    if (method) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id value = [self performSelector:NSSelectorFromString(@"valueForUndefinedKey:") withObject:key];
#pragma clang diagnostic pop
        return value;
    }
    @throw [NSException exceptionWithName:@"UnknownKeyException" reason:[NSString stringWithFormat:@"[%@ valueForUndefinedKey:]: this class is not key value coding-compliant for the key name.", self] userInfo:nil];
    return nil;
}

- (id)getIvarWithKey:(NSString *)key {
    Ivar ivar = class_getInstanceVariable([self class], key.UTF8String);
    return object_getIvar(self, ivar);
}

@end
