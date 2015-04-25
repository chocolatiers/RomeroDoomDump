
#import <appkit/appkit.h>

@interface TextLog:Object
{
	id	text_i;
	id	window_i;
}

- msg:(char *)string;
- display:sender;
- clear:sender;

@end
