#import "wadfiles.h"
#import "Coordinator.h"
#import "PatchPalette.h"
#import "PlanePalette.h"
#import "PlanePalView.h"

@implementation PlanePaletteView

- initFrame:(const NXRect *)theFrame
{
	[super	initFrame:theFrame];
	planePalView_i = self;
	selectedPlane = 0;
	return self;
}

- (int)currentViewSelection
{
	return selectedPlane;
}

- drawSelf:(const NXRect *)rects :(int)rectCount
{
	int planenum;
	apatch_t *plane;

	planenum = 0;
	while ((plane = [planePalette_i	getPlane:planenum++]) != NULL)
		if (NXIntersectsRect(&plane->r,&rects[0]))
			[plane->image		composite:NX_COPY toPoint:&plane->r.origin];
	
	if (selectedPlane >= 0)
	{
		NXRect	clipview,r;

		[self	getFrame:&clipview];
		plane = [planePalette_i	getPlane:selectedPlane];
		r = plane->r;
		r.origin.x -= 5;
		r.origin.y -= 5;
		r.size.width += 10;
		r.size.height += 10;
		NXDrawGroove(&r,&clipview);
		[plane->image		composite:NX_COPY toPoint:&plane->r.origin];
	}
	
	return self;
}

- mouseDown:(NXEvent *)theEvent
{
	NXPoint	loc;
	int		planenum;
	apatch_t *plane;
	
	loc = theEvent->location;
	[self convertPoint:&loc	fromView:NULL];
	
	planenum = 0;
	while ((plane = [planePalette_i	getPlane:planenum++]) != NULL)
		if ([self	mouse:&loc	inRect:&plane->r] == YES)
		{
			if (selectedPlane == planenum -1)
				[coordinator_i	playPop];
			else
			{
				selectedPlane = planenum - 1;
				[coordinator_i	playDrip];
			}
			[superview	display];
			break;
		}

	return self;
}




@end
