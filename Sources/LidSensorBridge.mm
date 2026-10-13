#import "LidSensorBridge.h"
#import <IOKit/IOKitLib.h>

@implementation LidSensorBridge

+ (double)getLidAngle {
    double angle = 180.0; // Default to fully open if sensor lookup fails
    
    // Modern MacBooks use 'AppleSmartDisplayHinge' to expose the physical lid angle
    CFMutableDictionaryRef matchingDict = IOServiceMatching("AppleSmartDisplayHinge");
    if (!matchingDict) {
        // Fallback matching for legacy or specific architecture variations
        matchingDict = IOServiceMatching("AppleDisplayHinge");
    }
    
    if (matchingDict) {
        io_iterator_t iterator;
        if (IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &iterator) == kIOReturnSuccess) {
            io_object_t serviceDevice;
            // Retrieve the first service matching the hinge sensor registry entry
            if ((serviceDevice = IOIteratorNext(iterator))) {
                CFTypeRef angleRef = IORegistryEntryCreateCFProperty(serviceDevice, CFSTR("LidAngle"), kCFAllocatorDefault, 0);
                if (angleRef) {
                    if (CFGetTypeID(angleRef) == CFNumberGetTypeID()) {
                        CFNumberGetValue((CFNumberRef)angleRef, kCFNumberDoubleType, &angle);
                    }
                    CFRelease(angleRef);
                }
                IOObjectRelease(serviceDevice);
            }
            IOObjectRelease(iterator);
        }
    }
    return angle;
}

@end
