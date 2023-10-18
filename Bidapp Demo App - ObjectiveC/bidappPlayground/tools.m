//
//  tools.m
//  bidappPlayground
//
//  Created by Mikhail Krasnorutskiy on 19/10/23.
//

#import "tools.h"

NSString* sessionIdShort(NSString* sessionId)
{
    if (sessionId.length > 3)
    {
        return [sessionId substringToIndex:3];
    }
    
    return sessionId;
}
