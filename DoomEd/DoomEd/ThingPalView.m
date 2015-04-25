
#import "ThingPalView.h"
#import	"ThingPalette.h"
#import	"DoomProject.h"
#import	"ThingPanel.h"

@implementation ThingPalView

- drawSelf:(const NXRect *)rects :(int)rectCount
{
	icon_t	*icon;
	int		max;
	int		i;
	int		ci;
	NXRect	r;
	NXPoint	p;
	
	ci = [thingPalette_i	getCurrentIcon];
	if (ci >= 0)
	{
		icon = [thingPalette_i	getIcon:ci];
		r = icon->r;
		r.origin.x -= 5;
		r.origin.y -= 5;
		r.size.width += 10;
		r.size.height += 10;
		DE_DrawOutline(&r);
	}
	
	max = [thingPalette_i	getNumIcons];
	for (i = 0; i < max; i++)
	{
		icon = [thingPalette_i	getIcon:i];
		if (NXIntersectsRect(&rects[0],&icon->r) == YES)
		{
			p = icon->r.origin;
			p.x += (ICONSIZE - icon->imagesize.width)/2;
			p.y += (ICONSIZE - icon->imagesize.height)/2;
			[icon->image	composite:NX_SOVER	toPoint:&p];
		}
	}

	//
	//	Draw icon divider text
	//
	PSselectfont("Helvetica-Bold",12);
	PSrotate ( 0 );
	for (i = 0; i < max; i++)
	{
		icon = [thingPalette_i	getIcon:i ];
		if (icon->image != NULL)
			continue;
			
		PSsetgray ( 0 );
		PSmoveto( icon->r.origin.x,icon->r.origin.y + ICONSIZE/2);
		PSshow ( icon->name );
		PSstroke ();

		PSsetrgbcolor ( 148,0,0 );
		PSsetlinewidth( 1.0 );
		PSmoveto ( icon->r.origin.x, icon->r.origin.y + ICONSIZE/2 + 12 );
		PSlineto ( bounds.size.width - SPACING,
				icon->r.origin.y + ICONSIZE/2 + 12 );

		PSmoveto ( icon->r.origin.x, icon->r.origin.y + ICONSIZE/2 - 2 );
		PSlineto ( bounds.size.width - SPACING,
				icon->r.origin.y + ICONSIZE/2 - 2 );
		PSstroke ();
	}
	
	return self;
}

- mouseDown:(NXEvent *)theEvent
{
	NXPoint	loc;
	int		i;
	int		max;
	int		oldwindowmask;
	icon_t	*icon;

	oldwindowmask = [window addToEventMask:NX_LMOUSEDRAGGEDMASK];
	loc = theEvent->location;
	[self convertPoint:&loc	fromView:NULL];
	
	max = [thingPalette_i	getNumIcons];
	for (i = 0;i < max; i++)
	{
		icon = [thingPalette_i		getIcon:i];
		if (NXPointInRect(&loc,&icon->r) == YES)
		{
			[thingPalette_i	setCurrentIcon:i];
			[thingpanel_i	selectThingWithIcon:icon->name];
			break;
		}
	}
	
	[window	setEventMask:oldwindowmask];
	return self;
}

@end
