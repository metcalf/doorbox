//
//  DBRequest.h
//  Doorbox
//
//  Created by Andrew Metcalf on 3/15/13.
//  Copyright (c) 2013 Andrew Metcalf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBSession.h"
#import <CoreLocation/CoreLocation.h>

typedef enum {
    DBMonday = 1,
    DBTuesday = 1 << 1,
    DBWednesday = 1 << 2,
    DBThursday = 1 << 3,
    DBFriday = 1 << 4,
    DBSaturday = 1 << 5,
    DBSunday = 1 << 6
} DBDayType;

@class DBRequest;

typedef void (^DBRequestHandler)(DBRequest *request,
    id result,
    NSError *error);

@interface DBRequest : NSObject

- (id)initWithSession:(DBSession*)session
             endpoint:(NSString*)endpoint
           parameters:(NSDictionary*)parameters
           httpMethod:(NSString*)httpMethod;

- (void) startWithCompletionHandler:(DBRequestHandler)handler;

@property (nonatomic, readonly) NSDictionary *parameters;
@property (nonatomic, readonly) DBSession *session;
@property (nonatomic, copy, readonly) NSString *endpoint;
@property (nonatomic, copy, readonly) NSString *httpMethod;

@property (nonatomic) id mockResponseResult;
@property (nonatomic) NSError *mockResponseError;

// TODO: Handle updating client info, push token


+ (DBRequest*) getDoorphone;

+ (DBRequest*) createDoorphoneWithLocation:(CLLocationCoordinate2D)location
                                    radius:(CLLocationDistance)radius;
+ (DBRequest*) updateDoorphone:(NSString*)doorphoneId
                    accessCode:(NSString*)code;
+ (DBRequest*) updateDoorphone:(NSString *)doorphoneId
                        active:(BOOL)active;
/*
+ (DBRequest*) deleteDoorphpone:(NSString*)doorphoneId;
+ (DBRequest*) lockMyDoorphone;
+ (DBRequest*) testCall;
+ (DBRequest*) unlockDoorphone:(NSString*)doorphoneId;
+ (DBRequest*) unlockMyDoorphoneWithRelockTime:(NSInteger*)relockMinutes
                            relockVisits:(NSInteger)relockVisits;

// Retrieved client should include last log entry
+ (DBRequest*) getClients;
+ (DBRequest*) updateClient;
+ (DBRequest*) deleteClient:(NSString*)clientId;

+ (DBRequest*) getSettings;
+ (DBRequest*) setAutoUnlock:(BOOL)state;
+ (DBRequest*) setNotifications:(NSArray*)notifications;

+ (DBRequest*) getSharingKeys;
+ (DBRequest*) getSharedKeys;
+ (DBRequest*) setAnytimeKeyByFacebookId:(NSString*)facebookId;
+ (DBRequest*) setRecurringKeyByFacebookId:(NSString*)facebookId
                                days:(uint8_t)days
                         startMinute:(NSInteger)startMinute
                           endMinute:(NSInteger)endMinute;
+ (DBRequest*) setOneTimeKeyByFacebookId:(NSString*)facebookId
                             start:(NSDate*)startDate
                               end:(NSDate*)endDate
                        entryLimit:(NSInteger)entryLimit;
+ (DBRequest*) deleteKeyByFacebookId:(NSString*)facebookId;
*/
+ (DBRequest*) getLogEventsWithLimit:(uint8_t)limit;


@end
