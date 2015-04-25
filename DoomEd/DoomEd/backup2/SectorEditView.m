#import	"DoomProject.h"
#import	"SectorEditor.h"
#import	"SectorPalette.h"
#import "SectorEditView.h"

@implementation SectorEditView

- drawSelf:(const NXRect *)rects :(int)rectCount
{
	sector_t	*s;
	flat_t	*f;
	int	cs;
	NXRect	r;
	NXPoint	p;
	
	cs = [sectorPalette_i	getCurrentSector];
	if (cs < 0)
		return self;
	s = [sectorPalette_i		getSector:cs];
		
	PSsetgray(NX_LTGRAY);
	NXSetRect(&r,0,0,128,200);
	NXRectFill(&r);
	//
	// Draw limit lines
	//
	NXSetColor(NXConvertRGBToColor(1,0,0));
	PSmoveto(0,50);
	PSlineto(127,50);
	PSmoveto(0,150);
	PSlineto(127,150);

	//
	// Draw ceiling
	//
	if (!s->w.s.ceilingflat[0])
	{
		NXSetRect(&r,32,s->w.s.ceilingheight/2 + 50,64,64);
		NXRectFill(&r);
	}
	else
	{
		f = [sectorEdit_i	getFlat:s->ceiling_flat];
		p.x = 32;
		p.y = s->w.s.ceilingheight/2 + 50;
		[f->image	composite:NX_COPY	toPoint:&p];
	}
	
	//
	// Draw floor
	//
	if (!s->w.s.floorflat[0])
	{
		NXSetRect(&r,32,s->w.s.floorheight/2 - 14,64,64);
		NXRectFill(&r);
	}
	else
	{
		f = [sectorEdit_i	getFlat:s->floor_flat];
		p.x = 32;
		p.y = s->w.s.floorheight/2 - 14;
		[f->image	composite:NX_COPY	toPoint:&p];
	}

	PSstroke();

	return self;
}

- mouseDown:(NXEvent *)theEvent
{
	NXPoint	loc;
	int	oldwindowmask, cs, ny, yoff;
	sector_t	*s;
	NXEvent	*event;
	NXRect	r;

	oldwindowmask = [window addToEventMask:NX_LMOUSEDRAGGEDMASK];
	loc = theEvent->location;
	[self convertPoint:&loc	fromView:NULL];
	
	cs = [sectorPalette_i	getCurrentSector];
	if (cs < 0)
		return self;
	s = [sectorPalette_i		getSector:cs];
	r.origin.x = 32;
	r.size.height = r.size.width = 64;
	
	//
	// Check ceiling
	//
	r.origin.y = s->w.s.ceilingheight/2 + 50;
	if (NXPointInRect(&loc,&r) == YES)
	{
		[sectorEdit_i	selectCeiling];
		yoff = loc.y - r.origin.y;
		do
		{
			event = [NXApp getNextEvent: 	NX_MOUSEUPMASK |
										NX_MOUSEDRAGGEDMASK];
			loc = event->location;
			[self convertPoint:&loc	fromView:NULL];
			ny = (2 * (loc.y - yoff)) - 100;
			if (ny > 200)
				ny = 200;
			if (ny < 0)
				ny = 0;
			if (ny < s->w.s.floorheight)
				ny = s->w.s.floorheight;
			ny &= -8;
			s->w.s.ceilingheight = ny;
			[self	display];
			[sectorEdit_i	setCeiling:ny];
			
		} while (event->type != NX_MOUSEUP);
	}
	
	r.origin.y = s->w.s.floorheight/2 - 14;
	if (NXPointInRect(&loc,&r) == YES)
	{
		[sectorEdit_i	selectFloor];
		yoff = (r.origin.y + r.size.height) - loc.y;
		do
		{
			event = [NXApp getNextEvent: 	NX_MOUSEUPMASK |
										NX_MOUSEDRAGGEDMASK];
			loc = event->location;
			[self convertPoint:&loc	fromView:NULL];
			ny = (2 * (loc.y + yoff)) - 100;
			if (ny > 200)
				ny = 200;
			if (ny < 0)
				ny = 0;
			if (ny > s->w.s.ceilingheight)
				ny = s->w.s.ceilingheight;
			ny &= -8;
			s->w.s.floorheight = ny;
			[self	display];
			[sectorEdit_i	setFloor:ny];
			
		} while (event->type != NX_MOUSEUP);
	}
	
	[window	setEventMask:oldwindowmask];
	return self;
}

@end
