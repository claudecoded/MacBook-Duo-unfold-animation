#ifndef LidSensorBridge_h
#define LidSensorBridge_h

#import <Foundation/Foundation.h>

@interface LidSensorBridge : NSObject

/**
 * Retrieves the current hardware lid angle from AppleSmartDisplayHinge.
 * @return The angle in degrees (0.0 to 180.0), or 180.0 if the sensor is unavailable.
 */
+ (double)getLidAngle;

@end

#endif /* LidSensorBridge_h */
