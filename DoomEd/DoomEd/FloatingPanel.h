#import <appkit/appkit.h>

@interface FloatingPanel: Panel

- initContent:(const NXRect *)contentRect
style:(int)aStyle
backing:(int)bufferingType
buttonMask:(int)mask
defer:(BOOL)flag;

@end
