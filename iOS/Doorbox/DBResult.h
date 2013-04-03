//
//  DBResult.h
//  Doorbox
//
//  Created by Andrew Metcalf on 3/21/13.
//  Copyright (c) 2013 Andrew Metcalf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    DBDoorUnlocked = 0,
    DBDoorLocked = 1,
    DBDoorUnconfigured = 2
} DBDoorState;

typedef enum {
    DBLogUnlocked = 0,
    DBLogLocked = 1,
    DBLogMissed = 2
} DBLogType;

@interface DBResult : NSObject

- (id) initWithResponseDictionary:(NSDictionary*)response;

@end

@interface DBDoorphone : DBResult

@property (nonatomic) NSString *id;

@property (nonatomic) NSString *twilioNumber;
@property (nonatomic) NSString *accessCode;
@property (nonatomic) DBDoorState state;
@property (nonatomic) BOOL active;
@property (nonatomic) NSDate *relockTime;
@property (nonatomic) uint8_t relockVisits;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) double radius;

@end

@interface DBLogEntry : DBResult

@property (nonatomic) NSString *id;

@property (nonatomic) DBLogType type;
@property (nonatomic) NSString *text;
@property (nonatomic) NSDate *time;

@end