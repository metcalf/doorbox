//
//  DBRequest.m
//  Doorbox
//
//  Created by Andrew Metcalf on 3/15/13.
//  Copyright (c) 2013 Andrew Metcalf. All rights reserved.
//

#import "DBRequest.h"
#import "DBResult.h"

@implementation DBRequest

- (id)initWithSession:(DBSession*)session
             endpoint:(NSString*)endpoint
           parameters:(NSDictionary*)parameters
           httpMethod:(NSString*)httpMethod {
    if(self = [super init]) {
        _session = session;
        _endpoint = endpoint;
        _parameters = parameters;
        _httpMethod = httpMethod;
    }
    return self;
}

- (void) startWithCompletionHandler:(DBRequestHandler)handler{
    // TODO: implement this for realz with HTTP not mock handlers
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(onMockResponse:)
                                   userInfo:@{ @"handler": handler }
                                    repeats:NO];
}

- (void) onMockResponse:(NSTimer*)timer {
    DBRequestHandler handler = ((DBRequestHandler)timer.userInfo[@"handler"]);
    handler(self, self.mockResponseResult, self.mockResponseError);
}

+ (DBRequest*) getDoorphone {
    return [[DBRequest alloc] init];
}

+ (DBRequest*) createDoorphoneWithLocation:(CLLocationCoordinate2D)location
                                    radius:(CLLocationDistance)radius {
    return [[DBRequest alloc] init];
}

+ (DBRequest*) updateDoorphone:(NSString*)doorphoneId
                    accessCode:(NSString*)code {
    return [[DBRequest alloc] init];
}

+ (DBRequest*) updateDoorphone:(NSString *)doorphoneId
                        active:(BOOL)active {
    return [[DBRequest alloc] init];
}

+ (DBRequest*) getLogEventsWithLimit:(uint8_t)limit {
    return [[DBRequest alloc] init];
}

@end
