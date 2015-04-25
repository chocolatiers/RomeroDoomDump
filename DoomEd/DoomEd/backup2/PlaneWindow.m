#import "wadfiles.h"
#import "PatchPalette.h"
#import "PlanePalette.h"
#import "PlaneWindow.h"
#import "PlanePalView.h"

@implementation PlaneWindow

- (int)currentViewSelection
{
	return [planeDocView_i	currentViewSelection];
}

- init
{
	NXRect	contentframe,docframe;
	NXPoint	startPoint;

	//
	// initialize the window
	//
	NXSetRect(&contentframe,
			PLANEWINDOWX,
			PLANEWINDOWY,
			PLANEWINDOWWIDTH,
			PLANEWINDOWHEIGHT);

	[self
		initContent:		&contentframe
		style:			NX_RESIZEBARSTYLE
		backing:			NX_BUFFERED
		buttonMask:		NX_CLOSEBUTTONMASK | NX_MINIATURIZEBUTTONMASK
		defer:			NO
	];
	
	//
	// set delegate so I can trap "windowDidResize" messages
	//
	[self	setDelegate:self];
	[self setTitle: "Plane Palette"];
	
	//
	// setup scrollview
	//
	[[self		contentView]	getFrame:&contentframe];
	planeScrollView_i = [[[ScrollView	alloc]
					initFrame:	&contentframe]
					setVertScrollerRequired: YES];

	//
	// setup docview that's in the scrollview	
	//
	NXSetRect(&curWindowRect,0,0,0,0);
	[planeScrollView_i		getContentSize:&curWindowRect.size];
	[ self		computePlaneDocView:&docframe];
	//
	// if only a couple planes, don't make window default size
	//
	if (curWindowRect.size.height > docframe.size.height)
	{
		curWindowRect.size.height = docframe.size.height;
		[self	sizeWindow:curWindowRect.size.width :curWindowRect.size.height];
	}

	planeDocView_i	=
			[[PlanePaletteView	alloc]
				initFrame:	&docframe];
	[planeScrollView_i		setDocView:planeDocView_i];
	//
	// start plane palette at top of docview
	//
	startPoint = docframe.origin;
	startPoint.y = docframe.size.height - curWindowRect.size.height;
	[planeDocView_i		scrollPoint:&startPoint];
	
	[self		setContentView:planeScrollView_i];
	[self display];

	return self;
}

- (BOOL)canBecomeMainWindow
{
	return NO;
}

//
// compute the size of the docView and set the origin of all the patches
// within the docView.
//
- computePlaneDocView: (NXRect *)theframe
{
	int	x, y, planenum, maxheight;
	apatch_t		*plane;
	
	x = y =  SPACING;
	maxheight = planenum = 0;
	while ((plane = [planePalette_i getPlane:planenum++]) != NULL)
	{
		if (x + plane->r.size.width > curWindowRect.size.width && x != SPACING)
		{
			x = SPACING;
			y += maxheight + SPACING;
			maxheight = 0;
		}
		
		plane->r.origin.x = x;
		plane->r.origin.y = y;
		
		if (plane->r.size.height > maxheight)
			maxheight = plane->r.size.height;

		if (x + plane->r.size.width > curWindowRect.size.width && x == SPACING)
		{
			y += maxheight + SPACING;
			maxheight = 0;
		}			
		else
			x += plane->r.size.width + SPACING;
	}
	y += maxheight + SPACING;
	NXSetRect(theframe,0,0,curWindowRect.size.width + SPACING,y);
	
	//
	// now go through all the patches and reassign the coords so they
	// stack from top to bottom...
	//
	maxheight = planenum = 0;
	x = theframe->origin.x + SPACING;
	y = theframe->origin.y + theframe->size.height - SPACING;
	while ((plane = [planePalette_i	getPlane:planenum++]) != NULL)
	{
		if (x + plane->r.size.width > curWindowRect.size.width && x != SPACING)
		{
			x = SPACING;
			y -= maxheight + SPACING;
			maxheight = 0;
		}
		
		plane->r.origin.x = x;
		plane->r.origin.y = y - plane->r.size.height;

		if (plane->r.size.height > maxheight)
			maxheight = plane->r.size.height;

		if (x + plane->r.size.width > curWindowRect.size.width && x == SPACING)
		{
			y -= maxheight + SPACING;
			maxheight = 0;
		}			
		else
			x += plane->r.size.width + SPACING;
	}	

	return self;
}

- windowDidResize:sender
{
	NXRect	theFrame;
	
	NXSetRect(&curWindowRect,0,0,0,0);
	[planeScrollView_i		getContentSize:&curWindowRect.size];
	[self		computePlaneDocView:&theFrame];
	[planeDocView_i	sizeTo:theFrame.size.width :theFrame.size.height];

	return self;
}


@end
