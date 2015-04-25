//
// docview of Patch Palette in TextureEdit
//
#import	"Coordinator.h"
#import 	"TexturePatchView.h"
#import	"TextureEdit.h"
@implementation TexturePatchView

- drawSelf:(const NXRect *)rects :(int)rectCount
{
	int patchnum,selectedPatch;
	apatch_t *patch;

	selectedPatch = [textureEdit_i	getCurrentPatch];
	patchnum = 0;
	while ((patch = [textureEdit_i	getPatch:patchnum++]) != NULL)
		if (NXIntersectsRect(&patch->r,&rects[0]))
			[patch->image		composite:NX_COPY toPoint:&patch->r.origin];
	
	if (selectedPatch >= 0)
	{
		NXRect	clipview,r;

		[self	getFrame:&clipview];
		patch = [textureEdit_i	getPatch:selectedPatch];
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
	int		patchnum,selectedPatch;
	apatch_t *patch;
	
	loc = theEvent->location;
	[self convertPoint:&loc	fromView:NULL];
	
	selectedPatch = [textureEdit_i	getCurrentPatch];
	patchnum = 0;
	while ((patch = [textureEdit_i	getPatch:patchnum++]) != NULL)
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
				
			[textureEdit_i	setSelectedPatch:patchnum - 1];
			[superview	display];
			break;
		}

	return self;
}

@end
