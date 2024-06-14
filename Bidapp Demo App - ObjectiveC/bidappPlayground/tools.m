//
//  tools.m
//  bidappPlayground
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
