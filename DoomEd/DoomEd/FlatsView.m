#import	"DoomProject.h"
#import	"SectorEditor.h"
#import "FlatsView.h"

@implementation FlatsView
- initFrame:(const NXRect *)frameRect
{
	dividers_i = [	[ Storage alloc ]
				initCount:		0
				elementSize:	sizeof (divider_t )
				description:	NULL ];
				
	[super	initFrame:frameRect];
	return self;
}

- addDividerX:(int)x Y:(int)y String:(char *)string;
{
	divider_t		d;
	
	d.x = x;
	d.y = y;
	strcpy (d.string, string );
	[dividers_i	addElement:&d ];
	
	return self;
}

- dumpDividers
{
	[dividers_i	empty];
	return self;
}

- drawSelf:(const NXRect *)rects :(int)rectCount
{
	flat_t	*f;
	int	max, i, cf;
	NXRect	r;
	divider_t	*d;
	
	cf = [sectorEdit_i	getCurrentFlat];
	if (cf >= 0)
	{
		f = [sectorEdit_i	getFlat:cf];
		r = f->r;
		r.origin.x -= 5;
		r.origin.y -= 5;
		r.size.width += 10;
		r.size.height += 10;
		DE_DrawOutline(&r);
	}
	
	max = [sectorEdit_i	getNumFlats];
	for (i = 0; i < max; i++)
	{
		f = [sectorEdit_i	getFlat:i];
		if (NXIntersectsRect(&rects[0],&f->r))
			[f->image	composite:NX_COPY	toPoint:&f->r.origin];
	}

	//
	//	Draw flat set divider text
	//
	PSselectfont("Helvetica-Bold",12);
	PSrotate ( 0 );
	max = [dividers_i	count ];
	for (i = 0; i < max; i++)
	{
		d = [dividers_i	elementAt:i ];
		PSsetgray ( 0 );
		PSmoveto( d->x,d->y );
		PSshow ( d->string );
		PSstroke ();

		PSsetlinewidth(1.0);
		PSsetrgbcolor ( 148,0,0 );
		PSmoveto ( d->x, d->y + 12 );
		PSlineto ( bounds.size.width - SPACING, d->y + 12 );

		PSmoveto ( d->x, d->y - 2 );
		PSlineto ( bounds.size.width - SPACING, d->y - 2 );
		PSstroke ();
	}
	
	return self;
}

- mouseDown:(NXEvent *)theEvent
{
	NXPoint	loc;
	int	i,max,oldwindowmask;
	flat_t	*f;

	oldwindowmask = [window addToEventMask:NX_LMOUSEDRAGGEDMASK];
	loc = theEvent->location;
	[self convertPoint:&loc	fromView:NULL];
	
	max = [sectorEdit_i	getNumFlats];
	for (i = 0;i < max; i++)
	{
		f = [sectorEdit_i		getFlat:i];
		if (NXPointInRect(&loc,&f->r) == YES)
		{
			if (theEvent->data.mouse.click == 2)
				[sectorEdit_i	selectFlat:i];
			else
				[sectorEdit_i	setCurrentFlat:i];
				
			break;
		}
	}
	
	[window	setEventMask:oldwindowmask];
	return self;
}

@end
