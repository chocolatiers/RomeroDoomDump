
#import <appkit/appkit.h>

@interface SpecialListWindow:Window
{
	id	parent_i;
	char	string[32];
}

- setParent:(id)p;

@end
