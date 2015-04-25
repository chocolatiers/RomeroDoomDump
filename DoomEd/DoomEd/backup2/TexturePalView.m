#import	"TexturePalette.h"
#import	"TextureEdit.h"
#import "TexturePalView.h"

@implementation TexturePalView

- drawSelf:(const NXRect *)rects :(int)rectCount
{
	int	count;
	texpal_t	*t;
	NXRect	r;
	
	//
	// draw selected texture outline
	//
	if ([texturePalette_i	currentSelection] >= 0)
	{
		t = [texturePalette_i		getTexture:[texturePalette_i currentSelection]];
		r = t->r;
		r.origin.x -= SPACING/2;
		r.origin.y -= SPACING/2;
		r.size.width += SPACING;
		r.size.height += SPACING;
		NXDrawGroove(&r,&r);
	}
	
	//
	// draw textures
	//
	count = 0;
	while ((t = [texturePalette_i	getTexture:count]) != NULL)
	{
		[t->image	composite:NX_COPY	toPoint:&t->r.origin];
		count++;
	}
	
	return self;
}

- mouseDown:(NXEvent *)theEvent
{
	NXPoint	loc;
	int	i,texcount,oldwindowmask;
	texpal_t	*t;

	oldwindowmask = [window addToEventMask:NX_LMOUSEDRAGGEDMASK];
	loc = theEvent->location;
	[self convertPoint:&loc	fromView:NULL];
	
	texcount = [texturePalette_i	getNumTextures];
	for (i = texcount - 1;i >= 0;i--)
	{
		t = [texturePalette_i		getTexture:i];
		if (NXPointInRect(&loc,&t->r) == YES)
		{
			[texturePalette_i	selectTexture:i];
			if (theEvent->data.mouse.click == 2)
			{
				[textureEdit_i	menuTarget:NULL];
				[textureEdit_i	newSelection:i];
				break;
			}
		}
	}
	return self;
}

@end
