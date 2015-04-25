//
// This belongs to TextureEdit (docView of TextureEdit's ScrollView)
//
#import "TextureEdit.h"
#import "EditWorld.h"
#import "TextureView.h"
#import "wadfiles.h"


@implementation TextureView

- (BOOL) acceptsFirstResponder
{
	return YES;
}

- initFrame:(const NXRect *)frameRect
{
	[super initFrame:frameRect];
	patchSelections = [[ Storage	alloc ]
					initCount:0
					elementSize:sizeof(store_t)
					description:NULL];

	return self;
}

- keyDown:(NXEvent *)theEvent
{
	switch(theEvent->data.key.charCode)
	{
		case 0x7f:	// delete patch
			[textureEdit_i	deleteCurrentPatch:NULL];
			break;
		case 0x6c:	// toggle lock
			[textureEdit_i	doLockToggle];
			break;
		case 0xac:
		case 0xaf:	// sort down
			[textureEdit_i	sortDown:NULL];
			break;
		case 0xad:
		case 0xae:	// sort up
			[textureEdit_i	sortUp:NULL];
			break;
		case 0xd:
			[textureEdit_i	finishTexture:NULL];
			break;
		#if 0
		default:
			printf("charCode:%x\n",theEvent->data.key.charCode);
			break;
		#endif
	}
	return self;
}

- drawSelf:(const NXRect *)rects :(int)rectCount
{
	int		ct,i,outlineflag;
	int		patchCount,cp;
	texpatch_t	*tpatch;
	
	ct = [textureEdit_i	getCurrentTexture];
	NXSetColor(NXConvertRGBAToColor(1,0,0,1));
	NXRectFill(&rects[0]);
	
	outlineflag = [textureEdit_i	getOutlineFlag];
	PSsetgray(NX_DKGRAY);
	patchCount = [texturePatches	count];
	for (i = 0;i < patchCount; i++)
	{
		tpatch = [texturePatches	elementAt:i];
//		if (NXIntersectsRect(&tpatch->r,&rects[0]))
			[tpatch->patch->image_x2	composite:NX_SOVER toPoint:&tpatch->r.origin];
	}

	if (outlineflag)
		for (i = patchCount - 1;i >= 0;i--)
		{
			tpatch = [texturePatches	elementAt:i];
//			if (NXIntersectsRect(&tpatch->r,&rects[0]))
				NXFrameRectWithWidth(&tpatch->r,5);
		}

	cp = [textureEdit_i	getCurrentEditPatch];
	if (cp >= 0)
	{
		tpatch = [texturePatches	elementAt:cp];
		PSsetgray(NX_WHITE);
		NXFrameRectWithWidth(&tpatch->r,5);
	}
	
	//
	// if multiple selections, draw their outlines
	//
	if ([patchSelections		count])
	{
		int	max;
		
		max = [patchSelections	count];
		for (i = 0;i<max;i++)
		{
			tpatch = [texturePatches	elementAt:((store_t *)[patchSelections elementAt:i])->sel];
			PSsetgray(NX_WHITE);
			NXFrameRectWithWidth(&tpatch->r,5);
		}
	}
	
	return self;
}

- mouseDown:(NXEvent *)theEvent
{
	NXPoint	loc;
	int	i,patchcount,oldwindowmask,xoff,yoff,ct;
	texpatch_t	*patch;

	oldwindowmask = [window addToEventMask:NX_LMOUSEDRAGGEDMASK];
	loc = theEvent->location;
	[self convertPoint:&loc	fromView:NULL];
	ct = [textureEdit_i	getCurrentTexture];

	patchcount = [texturePatches	count];
	for (i = patchcount - 1;i >= 0;i--)
	{
		patch = [texturePatches	elementAt:i];
		if (NXPointInRect(&loc,&patch->r) == YES)
		{
			NXEvent	*event;
			
			//
			// shift-click adds the patch to the select list
			//
			if (theEvent->flags & NX_SHIFTMASK)
			{
				int	max,indx;
				texpatch_t	*p;
				
				if (([textureEdit_i	getCurrentEditPatch] != -1) &&
					([textureEdit_i	getCurrentEditPatch] != i))
				{
					max = [patchSelections	count];
					for (indx = 0;indx < max;indx++)
					{
						p = [texturePatches elementAt:
								((store_t *)[patchSelections elementAt:indx])->sel];
						if (NXPointInRect(&loc,&p->r) == YES)
						{
							NXBeep();
							printf("Clicking on patch already selected!\n");
							return self;
						}
					}
					[patchSelections	addElement:&i];
					[self		display];
					return self;
				}
			}
	
			[textureEdit_i	setCurrentEditPatch:i];
			xoff = loc.x - patch->r.origin.x;
			yoff = loc.y - patch->r.origin.y;
			do
			{
				event = [NXApp getNextEvent: NX_MOUSEUPMASK |										NX_MOUSEDRAGGEDMASK];
				loc = event->location;
				[self convertPoint:&loc	fromView:NULL];
				loc.x = ((int)loc.x - xoff) & -2;
				loc.y = ((int)loc.y - yoff) & -2;
				patch->r.origin = loc;
				patch->patchInfo.originx = loc.x / 2;
				patch->patchInfo.originy = textures[ct].height - 
									((loc.y / 2) + (patch->r.size.height / 2));
				[ self		display];
			} while (event->type != NX_MOUSEUP);

			[textureEdit_i	setOldVars:patch->patchInfo.originx + patch->r.size.width/2
						:patch->patchInfo.originy];
			break;
		}
	}
	return self;
}

@end
