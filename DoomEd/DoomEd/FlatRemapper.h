#import	"Remapper.h"
#import <appkit/appkit.h>

extern	id	flatRemapper_i;

@interface FlatRemapper:Object <Remapper>
{
	id	remapper_i;
}

- addToList:(char *)orgname to:(char *)newname;

@end
