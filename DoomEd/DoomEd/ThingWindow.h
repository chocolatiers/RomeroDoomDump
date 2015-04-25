
#import <appkit/appkit.h>

@interface ThingWindow:Window
{
	id	parent_i;
	char	string[32];
}

- setParent:(id)p;


@end
