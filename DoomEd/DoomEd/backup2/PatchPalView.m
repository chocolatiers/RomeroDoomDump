#import "idfunctions.h"
#import "wadfiles.h"
#import "Coordinator.h"
#import "PatchPalette.h"
#import "PatchPalView.h"
#import "TextureEdit.h"

@implementation PatchPaletteView

- initFrame:(const NXRect *)theFrame
{
	[super	initFrame:theFrame];
	patchPalView_i = self;
	selectedPatch = 0;
	return self;
}

- (int)currentSelection
{
	return selectedPatch;
}

- drawSelf:(const NXRect *)rects :(int)rectCount
{
	int patchnum;
	apatch_t *patch;

	patchnum = 0;
	while ((patch = [patchPalette_i	getPatch:patchnum++]) != NULL)
		if (NXIntersectsRect(&patch->r,&rects[0]))
			[patch->image		composite:NX_COPY toPoint:&patch->r.origin];
	
	if (selectedPatch >= 0)
	{
		NXRect	clipview,r;

		[self	getFrame:&clipview];
		patch = [patchPalette_i	getPatch:selectedPatch];
		r = patch->r;
		r.origin.x -= 5;
		r.origin.y -= 5;
		r.size.width += 10;
		r.size.height += 10;
		NXDrawGroove(&r,&clipview);
		[patch->image		composite:NX_COPY toPoint:&patch->r.origin];
	}
	
	return self;
}

- mouseDown:(NXEvent *)theEvent
{
	NXPoint	loc;
	int		patchnum;
	apatch_t *patch;
	
	loc = theEvent->location;
	[self convertPoint:&loc	fromView:NULL];
	
	patchnum = 0;
	while ((patch = [patchPalette_i	getPatch:patchnum++]) != NULL)
		if ([self	mouse:&loc	inRect:&patch->r] == YES)
		{
			if (selectedPatch == patchnum -1)
				[coordinator_i	playPop];
			else
			{
				selectedPatch = patchnum - 1;
				[coordinator_i	playDrip];
			}
			
			if (theEvent->data.mouse.click == 2)
				[textureEdit_i	addPatch:selectedPatch];
				
			[superview	display];
			break;
		}

	return self;
}


@end
