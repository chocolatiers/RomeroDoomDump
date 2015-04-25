#import "lbmfunctions.h"
#import "wadfiles.h"
#import "PatchPalette.h"
#import "PatchWindow.h"
#import "PatchPalView.h"

@implementation PatchWindow

- (int)currentViewSelection
{
	return [patchDocView_i	currentSelection];
}

- init
{
	NXRect	contentframe,docframe;
	NXPoint	startPoint;

	//
	// initialize the window
	//
	NXSetRect(&contentframe,
			PATCHWINDOWX,
			PATCHWINDOWY,
			PATCHWINDOWWIDTH,
			PATCHWINDOWHEIGHT);

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
	[self setTitle: "Patch Palette"];
	
	//
	// setup scrollview
	//
	[[self		contentView]	getFrame:&contentframe];
	patchScrollView_i = [[[ScrollView	alloc]
					initFrame:	&contentframe]
					setVertScrollerRequired: YES];

	//
	// setup docview that's in the scrollview	
	//
	NXSetRect(&curWindowRect,0,0,0,0);
	[patchScrollView_i		getContentSize:&curWindowRect.size];
	[ self		computePatchDocView:&docframe];
	//
	// if only a couple patches, don't make window default size
	//
	if (curWindowRect.size.height > docframe.size.height)
	{
		curWindowRect.size.height = docframe.size.height;
		[self	sizeWindow:curWindowRect.size.width :curWindowRect.size.height];
	}

	patchDocView_i	=
			[[PatchPaletteView	alloc]
				initFrame:	&docframe];
	[patchScrollView_i		setDocView:patchDocView_i];
	//
	// start patch palette at top of docview
	//
	startPoint = docframe.origin;
	startPoint.y = docframe.size.height - curWindowRect.size.height;
	[patchDocView_i		scrollPoint:&startPoint];
	
	[self		setContentView:patchScrollView_i];
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
- computePatchDocView: (NXRect *)theframe
{
	int	x, y, patchnum, maxheight;
	apatch_t		*patch;
	
	x = y =  SPACING;
	maxheight = patchnum = 0;
	while ((patch = [patchPalette_i getPatch:patchnum++]) != NULL)
	{
		if (x + patch->r.size.width > curWindowRect.size.width && x != SPACING)
		{
			x = SPACING;
			y += maxheight + SPACING;
			maxheight = 0;
		}
		
		patch->r.origin.x = x;
		patch->r.origin.y = y;
		
		if (patch->r.size.height > maxheight)
			maxheight = patch->r.size.height;

		if (x + patch->r.size.width > curWindowRect.size.width && x == SPACING)
		{
			y += maxheight + SPACING;
			maxheight = 0;
		}			
		else
			x += patch->r.size.width + SPACING;
	}
	y += maxheight + SPACING;
	NXSetRect(theframe,0,0,curWindowRect.size.width + SPACING,y);
	
	//
	// now go through all the patches and reassign the coords so they
	// stack from top to bottom...
	//
	maxheight = patchnum = 0;
	x = theframe->origin.x + SPACING;
	y = theframe->origin.y + theframe->size.height - SPACING;
	while ((patch = [patchPalette_i	getPatch:patchnum++]) != NULL)
	{
		if (x + patch->r.size.width > curWindowRect.size.width && x != SPACING)
		{
			x = SPACING;
			y -= maxheight + SPACING;
			maxheight = 0;
		}
		
		patch->r.origin.x = x;
		patch->r.origin.y = y - patch->r.size.height;

		if (patch->r.size.height > maxheight)
			maxheight = patch->r.size.height;

		if (x + patch->r.size.width > curWindowRect.size.width && x == SPACING)
		{
			y -= maxheight + SPACING;
			maxheight = 0;
		}			
		else
			x += patch->r.size.width + SPACING;
	}	

	return self;
}

- windowDidResize:sender
{
	NXRect	theFrame;
	
	NXSetRect(&curWindowRect,0,0,0,0);
	[patchScrollView_i		getContentSize:&curWindowRect.size];
	[self		computePatchDocView:&theFrame];
	[patchDocView_i	sizeTo:theFrame.size.width :theFrame.size.height];

	return self;
}

@end

