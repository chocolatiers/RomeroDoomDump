#import	"DoomProject.h"
#import	"SectorEditor.h"
#import "FlatsView.h"

@implementation FlatsView

- drawSelf:(const NXRect *)rects :(int)rectCount
{
	flat_t	*f;
	int	max, i, cf;
	NXRect	r;
	
	cf = [sectorEdit_i	getCurrentFlat];
	if (cf >= 0)
	{
		f = [sectorEdit_i	getFlat:cf];
		r = f->r;
		r.origin.x -= 5;
		r.origin.y -= 5;
		r.size.width += 10;
		r.size.height += 10;
		NXDrawGroove(&r,&bounds);
	}
	
	max = [sectorEdit_i	getNumFlats];
	for (i = 0; i < max; i++)
	{
		f = [sectorEdit_i	getFlat:i];
		[f->image	composite:NX_COPY	toPoint:&f->r.origin];
	}
	
	return self;
}

- mouseDown:(NXEvent *)theEvent
{
	NXPoint	loc;
	int	i,max,oldwindowmask;
	flat_t	*f;

	if (theEvent->data.mouse.click != 2)
		return self;
		
	oldwindowmask = [window addToEventMask:NX_LMOUSEDRAGGEDMASK];
	loc = theEvent->location;
	[self convertPoint:&loc	fromView:NULL];
	
	max = [sectorEdit_i	getNumFlats] - 1;
	for (i = 0;i < max; i++)
	{
		f = [sectorEdit_i		getFlat:i];
		if (NXPointInRect(&loc,&f->r) == YES)
		{
			[sectorEdit_i	selectFlat:i];
			break;
		}
	}
	
	[window	setEventMask:oldwindowmask];
	return self;
}

@end
