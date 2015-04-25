#import	"Remapper.h"
#import <appkit/appkit.h>

extern	id	textureRemapper_i;

@interface TextureRemapper:Object <Remapper>
{
	id	remapper_i;
}

- addToList:(char *)orgname to:(char *)newname;

@end
