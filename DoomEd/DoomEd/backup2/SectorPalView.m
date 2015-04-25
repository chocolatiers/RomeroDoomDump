#import	"SectorEditor.h"
#import	"SectorPalette.h"
#import "SectorPalView.h"

@implementation SectorPalView

- drawSelf:(const NXRect *)rects :(int)rectCount
{
	int	max, i, cs;
	sector_t	*s;
	NXRect	r;
	
	cs = [sectorPalette_i	getCurrentSector];
	if (cs >= 0)
	{
		s = [sectorPalette_i		getSector:cs];
		r = s->r;
		r.origin.x -= 5;
		r.origin.y -= 5;
		r.size.width += 10;
		r.size.height += 10;
		NXDrawGroove(&r,&r);
	}
	
	max = [sectorPalette_i	getNumSectors];
	for (i = 0; i < max; i++)
	{
		s = [sectorPalette_i		getSector:i];
		[s->image	composite:NX_COPY	toPoint:&s->r.origin];
	}
	
	return self;
}

- mouseDown:(NXEvent *)theEvent
{
	NXPoint	loc;
	int	i,max,oldwindowmask;
	sector_t	*s;

	oldwindowmask = [window addToEventMask:NX_LMOUSEDRAGGEDMASK];
	loc = theEvent->location;
	[self convertPoint:&loc	fromView:NULL];
	
	max = [sectorPalette_i	getNumSectors];
	for (i = 0;i < max; i++)
	{
		s = [sectorPalette_i		getSector:i];
		if (NXPointInRect(&loc,&s->r) == YES)
		{
			[sectorPalette_i	setCurrentSector:i];
			[sectorEdit_i	changeSector:i];
			break;
		}
	}
	
	[window	setEventMask:oldwindowmask];
	return self;
}
@end
