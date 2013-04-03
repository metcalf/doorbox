//
//  DBResult.m
//  Doorbox
//
//  Created by Andrew Metcalf on 3/21/13.
//  Copyright (c) 2013 Andrew Metcalf. All rights reserved.
//

#import "DBResult.h"
#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>

@implementation DBResult

- (id)initWithResponseDictionary:(NSDictionary *)response {
    if(self = [super init]){
        // Set all properties from the dictionary
        [self setValuesForKeysWithDictionary:response];
        /*unsigned int outCount, i;
        NSString *propertyName;
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            propertyName = [NSString stringWithCString:property_getName(property) encoding:NSASCIIStringEncoding];
            [self setValue:[response objectForKey:propertyName] forKey:propertyName];
        }*/
    
        //free(properties);
    }
    return self;
}

@end

@implementation DBDoorphone
@end

@implementation DBLogEntry
@end
