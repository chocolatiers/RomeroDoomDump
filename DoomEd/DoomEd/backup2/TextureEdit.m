#import	"TextureEdit.h"
#import	"TexturePalette.h"
#import	"DoomProject.h"
#import	"Wadfile.h"
#import	<ctype.h>
#import	"lbmfunctions.h"

id	textureEdit_i;
id	texturePatches;

@implementation TextureEdit

- init
{
	window_i = NULL;
	textureEdit_i = self;
	currentTexture = -1; 
	oldx = oldy = 0;
	return self;
}

//
// user wants to activate the Texture Editor. If it hasn't been used yet,
// init everything, otherwise just pull it back up.
//
- menuTarget:sender
{
	if (![doomproject_i loaded])
	{
		NXRunAlertPanel("Oops!",
						"There must be a project loaded before you even\n"
						"THINK about editing textures!",
						"OK",NULL,NULL,NULL);
		return self;
	}
	
	if (!window_i)
	{
		NXSize	s;
		NXRect	dvf;
		NXPoint	startPoint;
		
		[NXApp 
			loadNibSection:	"TextureEdit.nib"
			owner:			self
			withNames:		NO
		];
		
		[window_i	setDelegate:self];
		[self		computePatchDocView:&dvf];
		[texturePatchView_i	sizeTo:dvf.size.width :dvf.size.height];

		//
		// start patches at top
		//
		[texturePatchScrollView_i	getContentSize:&s];
		startPoint.x = 0;
		startPoint.y = dvf.size.height - s.height;
		[texturePatchView_i		scrollPoint:&startPoint];

		//
		// start texture editor at top
		//
		[textureView_i		getFrame:&dvf];
		[scrollView_i		getContentSize:&s];
		startPoint.y = dvf.size.height - s.height;
		[textureView_i		scrollPoint:&startPoint];
	
		[self	setCurrentEditPatch:-1];
		[self	setSelectedPatch:0];
	}
	
	[self	newSelection:currentTexture];
	[window_i	makeKeyAndOrderFront:NULL];
	return self;
}

//=====================================================
//
//	TEXTURE PATCH STUFF
//
//=====================================================


//
// move a patch up in the patch hierarchy
//
- sortUp:sender
{
	int	newpatch;
	texpatch_t	*t, t1, t2;

	if ((currentPatch < 0) || ([texturePatches	count] - 1 == currentPatch))
	{
		NXBeep();
		return self;
	}
	
	t = [texturePatches	elementAt:currentPatch];
	if (t->patchLocked)
	{
		NXBeep();
		return self;
	}
	
	newpatch = currentPatch;
	do
	{
		newpatch++;
		t = [texturePatches	elementAt:newpatch];
		if (!t)
		{
			NXBeep();
			return self;
		}
	} while (t->patchLocked);

	t2 = *t;
	t = [texturePatches	elementAt:currentPatch];
	t1 = *t;
	[texturePatches	removeElementAt:newpatch];
	[texturePatches	removeElementAt:currentPatch];
	[texturePatches	insertElement:&t2	at:currentPatch];
	[texturePatches	insertElement:&t1	at:newpatch];
	[self	setCurrentEditPatch:newpatch];

	[textureView_i		display];
	return self;
}

//
// move a patch down in the patch hierarchy
//
- sortDown:sender
{
	int	newpatch;
	texpatch_t	*t, t1, t2;

	if (currentPatch < 1)
	{
		NXBeep();
		return self;
	}
	
	t = [texturePatches	elementAt:currentPatch];
	if (t->patchLocked)
	{
		NXBeep();
		return self;
	}
	
	newpatch = currentPatch;
	do
	{
		newpatch--;
		t = [texturePatches	elementAt:newpatch];
		if (!t)
		{
			NXBeep();
			return self;
		}
	} while (t->patchLocked);

	t2 = *t;
	t = [texturePatches	elementAt:currentPatch];
	t1 = *t;
	[texturePatches	removeElementAt:currentPatch];
	[texturePatches	removeElementAt:newpatch];
	[texturePatches	insertElement:&t1	at:newpatch];
	[texturePatches	insertElement:&t2	at:currentPatch];
	[self	setCurrentEditPatch:newpatch];

	[textureView_i		display];
	return self;
}

- deleteCurrentPatch:sender
{
	if (currentPatch < 0)
	{
		NXBeep();
		return self;
	}
	[texturePatches	removeElementAt:currentPatch];
	[self	setCurrentEditPatch:-1];
	[textureView_i		display];
	return self;
}

//
// set which patch is selected in edit view
//
- setCurrentEditPatch:(int)which
{
	texpatch_t	*t;
	
	currentPatch = which;
	if (which >= 0)
	{
		t = [texturePatches	elementAt:which];
		[lockedPatch_i	setEnabled:YES];
		[lockedPatch_i	setIntValue:t->patchLocked];
		[texturePatchWidthField_i	setIntValue:t->r.size.width / 2];
		[texturePatchHeightField_i	setIntValue:t->r.size.height / 2];
		[texturePatchNameField_i	setStringValue:t->patchInfo.patchname];
	}
	else
	{
		[lockedPatch_i	setEnabled:NO];
		[texturePatchWidthField_i	setStringValue:NULL];
		[texturePatchHeightField_i	setStringValue:NULL];
		[texturePatchNameField_i	setStringValue:NULL];
	}
	return self;
}

//
// return which patch is selected in edit view
//
- (int)getCurrentEditPatch
{
	return currentPatch;
}

//
// patch lock switch was modified, so change patch flag
//
- doLockToggle
{
	[lockedPatch_i	setIntValue:1 - [lockedPatch_i intValue]];
	[self	togglePatchLock:NULL];
	return self;
}

- togglePatchLock:sender
{
	int	val;
	texpatch_t	*t;
	
	if (currentPatch < 0)
	{
		NXBeep();
		return self;
	}
	val = [lockedPatch_i	intValue];
	t = [texturePatches	elementAt:currentPatch];
	t->patchLocked = val;
	return self;
}

//
// return current patch in edit window
//
- (int)getCurrentPatch
{
	return	selectedPatch;
}

//
// the "outline patches" switch was modified, so redraw edit view
//
- outlineWasSet:sender
{
	[window_i	display];
	return self;
}

//
// return status of outline switch
//
- (int)getOutlineFlag
{
	return [outlinePatches_i		intValue];
}

//
// return * to patch image object
//
- (apatch_t *)getPatch:(int)which
{
	return	[patchImages	elementAt:which];
}

//=====================================================
//
//	TEXTURE STUFF
//
//=====================================================


//
// user changed the width/height/title of the texture. validate & change.
//
- changedWidth:sender
{
	worldtexture_t		tex;
	texpatch_t		*p;
	int		count;
	NXRect	tr;
	
	//
	// was width reduced?
	//
	if ([textureWidthField_i	intValue] < textures[currentTexture].width - 10)
	{
		NXSetRect(&tr,0,0,textures[currentTexture].width * 2,textures[currentTexture].height * 2);
		count = 0;
		while((p = [texturePatches	elementAt:count++]) != NULL)
			if (NXIntersectsRect(&p->r,&tr) == NO)
			{
				NXBeep();
				NXRunAlertPanel("Oops!",
								"Changing the width like that would leave one or more "
								"patches out in limbo!  Sorry, non-workness!",
								"OK",NULL,NULL);
				return self;
			}
		
	}

	tex = textures[currentTexture];
	tex.width = [textureWidthField_i	intValue];
	[doomproject_i	changeTexture:currentTexture to:&tex];
	[texturePalette_i		storeTexture:currentTexture];
	[self	newSelection:currentTexture];
	return self;
}

- changedHeight:sender
{
	return self;
}

- changedTitle:sender
{
	return self;
}

//
// create a new texture
//
- makeNewTexture:sender
{
	int	textureNum,rcode;
	worldtexture_t		tex;
	
	if (![doomproject_i loaded])
		return self;
		
	//
	// create a default new texture
	//
	rcode = [NXApp	runModalFor:createTexture_i];
	[createTexture_i	close];
	if (rcode == NX_RUNABORTED)
		return self;

	tex.width = [createWidth_i	intValue];
	tex.height = [createHeight_i	intValue];
	memset(tex.name,0,9);
	strncpy(tex.name,[createName_i	stringValue],8);
	tex.patchcount = 0;
	
	//
	// add it to the world and edit it
	//
	textureNum = [doomproject_i	newTexture: &tex];
	[texturePalette_i	storeTexture: textureNum];
	[self	newSelection:textureNum];
	currentTexture = textureNum;
	//
	// load in all the texture patches
	//
	if (texturePatches)
		[texturePatches	free];
	texturePatches = [[	Storage	alloc]
					initCount:		0
					elementSize:	sizeof(texpatch_t)
					description:	NULL];
	[texturePalette_i	selectTexture:currentTexture];
	oldx = oldy = 0;			
	return self;
}

//
// clicked the "create it!" button in the New Texture dialog
//
- createTextureDone:sender
{
	char name[9];
	
	// clip texture name to 8 characters
	bzero(name,9);
	strncpy(name,[createName_i	stringValue],8);
	strupr(name);
	[createName_i	setStringValue:name];

	if (	[doomproject_i	textureNamed:name] >= -1)
	{
		NXBeep();
		NXRunAlertPanel("Oops!",
						"You already have a texture with the same name!",
						"OK",NULL, NULL, NULL);
		return self;
	}
	
	if (	[createWidth_i	intValue] &&
		[createHeight_i	intValue] &&
		strlen([createName_i	stringValue]))
		[NXApp	stopModal];
	else
		NXBeep();

	return self;
}

- createTextureAbort:sender
{
	[NXApp	abortModal];
	return self;
}

//
// done editing texture. add to texture palette
//
- finishTexture:sender
{
	int	count;
	texpatch_t	*t;
	worldtexture_t		tex;
	
	//
	// copy texture info into textures array, then
	// add texture to palette
	//
	count = 0;
	tex.patchcount = [texturePatches count];
	tex.width = textures[currentTexture].width;
	tex.height = textures[currentTexture].height;
	strcpy(tex.name,textures[currentTexture].name);
	while ([texturePatches	elementAt:count] != NULL)
	{
		t = [texturePatches elementAt:count];
		tex.patches[count] = t->patchInfo;
		count++;
	}
	[doomproject_i	changeTexture:currentTexture to:&tex];
	[texturePalette_i		storeTexture:currentTexture];
	
	return self;
}

//
// change to a new texture
//
- newSelection:(int)which
{
	texpatch_t	t;
	int	count,i;

	currentTexture = which;
	if (texturePatches)
		[texturePatches	free];
	
	texturePatches = [[	Storage	alloc]
					initCount:		0
					elementSize:	sizeof(texpatch_t)
					description:	NULL];
	
	//
	// copy textures from textures array to texturePatches
	//
	count = textures[which].patchcount;
	for (i = 0;i < count; i++)
	{
		t.patchLocked = 0;
		t.patchInfo = textures[which].patches[i];
		t.patch = [self	getPatchImage:t.patchInfo.patchname];
		t.r.origin.x = t.patchInfo.originx * 2;
		t.r.origin.y = (textures[which].height * 2) - 
					(t.patch->r.size.height * 2) - 
					(t.patchInfo.originy * 2);
		t.r.size.width = t.patch->r.size.width * 2;
		t.r.size.height = t.patch->r.size.height * 2;
		[texturePatches	addElement:&t];
	}	
	
	currentPatch = -1;
	[textureView_i		sizeTo:textures[currentTexture].width * 2
					:textures[currentTexture].height * 2];
	[textureView_i		display];
	
	[textureWidthField_i	setIntValue:textures[currentTexture].width];
	[textureHeightField_i	setIntValue:textures[currentTexture].height];
	[textureNameField_i	setStringValue:textures[currentTexture].name];
	
	return self;
}

//
// return which texture we're working on
//
- (int)getCurrentTexture
{
	return currentTexture;
}

- setOldVars:(int)x :(int)y
{
	oldx = x;
	oldy = y;
	return self;
}

//
// user double-clicked on patch in patch palette.
// add that patch to the texture definition.
//
- addPatch:(int)which
{
	int	start;
	NXRect	dvr;
	texpatch_t	p;
	
	[scrollView_i	getDocVisibleRect:&dvr];
	
	if (currentTexture < 0)
	{
		NXBeep();
		return self;
	}
	
	if ([texturePatches	count] == MAXPATCHES)
	{
		NXRunAlertPanel(	"Um!",
						"A maximum of 100 patches is in force!",
						"OK",NULL,NULL);
		return self;
	}
	
	memset(&p,0,sizeof(p));
	p.patchLocked = 0;
	p.patch = [patchImages	elementAt:which];

	if ([centerPatch_i intValue])
	{
		p.patchInfo.originx = dvr.origin.x/2 + dvr.size.width/4;
		p.patchInfo.originy = dvr.origin.y/2 + dvr.size.height/4;
	}
	else
	{
		if (oldx > textures[currentTexture].width)
		{
			NXBeep();
			[centerPatch_i	setIntValue:1];
			p.patchInfo.originx = dvr.origin.x/2 + dvr.size.width/4;
			p.patchInfo.originy = dvr.origin.y/2 + dvr.size.height/4;
		}
		else
		{
			p.patchInfo.originx = oldx;
			p.patchInfo.originy = oldy;
		}
	}
	oldx += p.patch->r.size.width;
	
	start = [wadfile_i	lumpNamed:"p_start"] + 1;
	memset(p.patchInfo.patchname,0,9);
	strcpy(p.patchInfo.patchname,[wadfile_i	lumpname:which + start]);
	p.patchInfo.stepdir = 1;
	p.patchInfo.colormap = 0;

	p.r.origin.x = p.patchInfo.originx * 2;
	p.r.origin.y = (textures[currentTexture].height * 2) - 
				(p.patch->r.size.height * 2) - 
				(p.patchInfo.originy * 2);
	p.r.size.width = p.patch->r.size.width * 2;
	p.r.size.height = p.patch->r.size.height * 2;
	
	[texturePatches	addElement:&p];
	currentPatch = [texturePatches	count] - 1; 
	[textureView_i		scrollRectToVisible:&p.r];
	[textureView_i		display];
	return self;
}

- fillWithPatch:sender
{
	return self;
}

- sizeChanged:sender
{
	return self;
}

//=====================================================
//
//	PATCH PALETTE STUFF
//
//=====================================================

- (apatch_t *)getPatchImage:(char *)name
{
	int	start;
	start = [wadfile_i	lumpNamed:"p_start"] + 1;
	return [patchImages		elementAt:[wadfile_i  lumpNamed:name] - start];
}

//
// set patch selected in Patch Palette
//
- setSelectedPatch:(int)which
{
	apatch_t	*t;
	int	start;
	
	start = [wadfile_i	lumpNamed:"p_start"] + 1;
	selectedPatch = which;
	t = [patchImages	elementAt:which];
	[patchWidthField_i		setIntValue:t->r.size.width];
	[patchHeightField_i	setIntValue:t->r.size.height];
	[patchNameField_i		setStringValue:[wadfile_i  lumpname:which + start]];
	return self;
}

//
// load in all the patches and init storage array
//
- initPatches
{
	int	patchStart, patchEnd, i;
	patch_t *patch;
	byte *palLBM;
	apatch_t	p;
	NXSize	s;

	palLBM = [wadfile_i	loadLumpNamed:"playpal"];
	
	//
	// get inclusive lump #'s for patches
	//
	patchStart = [wadfile_i	lumpNamed:"p_start"] + 1;
	patchEnd = [wadfile_i	lumpNamed:"p_end"];

	if (patchStart == -1)
	{
		NXRunAlertPanel(	"OOPS!",
						"There are NO PATCHES in the current .WAD file!",
						"Abort Patch Palette",NULL,NULL,NULL);
		free(palLBM);
		return self;
	}
	
	patchImages = [[Storage	alloc]
						initCount:		0
						elementSize:	sizeof(apatch_t)
						description:	NULL];
	
	NXSetRect(&p.r,0,0,0,0);
	for (i = patchStart; i < patchEnd; i++)
	{
		NXSize	theSize;
		//
		// load vertically compressed patch and convert to an NXImage
		//
		patch = [wadfile_i	loadLump:i];
		p.image = patchToImage(patch,palLBM,&s);
		//
		// make a copy that's 2 times the size
		//
		p.image_x2 = [p.image	copyFromZone:NXDefaultMallocZone()];
		theSize = s;
		theSize.width *= 2;
		theSize.height *= 2;
		[p.image_x2	setScalable:YES];
		[p.image_x2	setSize:&theSize];
		
		p.r.size = s;
		[patchImages	addElement:&p];
		free(patch);
	}
	
	free(palLBM);
	return self;
}

//
// user resized the Texture Edit window.
// change the size of the patch palette.
//
- windowDidResize:sender
{
	NXRect	r;
	
	[self		computePatchDocView:&r];
	[texturePatchView_i	sizeTo:r.size.width :r.size.height];
	[window_i	display];
	return self;
}

//
// compute the size of the docView and set the origin of all the patches
// within the docView.
//
- computePatchDocView: (NXRect *)theframe
{
	NXRect	curWindowRect;
	int	x, y, patchnum, maxheight;
	apatch_t		*patch;
	
	[texturePatchScrollView_i		getDocVisibleRect:&curWindowRect];
	x = y =  SPACING;
	maxheight = patchnum = 0;
	while ((patch = [patchImages	elementAt:patchnum++]) != NULL)
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
	while ((patch = [patchImages	elementAt:patchnum++]) != NULL)
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


@end

//---------------------------------------------------------------
//
// C ROUTINES
//
//---------------------------------------------------------------



//
// convert a compressed patch to an NXImage with an alpha channel
//
id	patchToImage(patch_t *patchData,byte const *lbmpalette,NXSize *size)
{
	byte			*dest_p;
	NXImageRep *image_i;
	id			fastImage_i;
	unsigned short	shortpal[256];
	int			width,height,count,topdelta;
	byte const	*data;
	int			i,index;

	width = patchData->width;
	height = patchData->height;
	size->width = width;
	size->height = height;
	//
	// make an NXimage to hold the data
	//
	image_i = [[NXBitmapImageRep alloc]
		initData:			NULL 
		pixelsWide:		width 
		pixelsHigh:		height
		bitsPerSample:	4
		samplesPerPixel:	4 
		hasAlpha:		YES
		isPlanar:			NO 
		colorSpace:		NX_RGBColorSpace 
		bytesPerRow:		width*2
		bitsPerPixel: 		16
	];

	if (!image_i)
		return nil;
				
	//
	// translate the picture
	//
	LBMpaletteTo16 (lbmpalette, shortpal);
	dest_p = [(NXBitmapImageRep *)image_i data];
	memset(dest_p,0,width * height * 2);
	
	for (i = 0;i < width; i++)
	{
		data = (byte *)patchData + ShortSwap(patchData->collumnofs[i]);
		while (1)
		{
			topdelta = *data++;
			if (topdelta == (byte)-1)
				break;
			count = *data++;
			index = (topdelta*width+i)*2;
			while (count--)
			{
				*((unsigned short *)(dest_p + index)) = shortpal[*data++];
				index += width * 2;
			}
		}
	}

	fastImage_i = [[NXImage	alloc]
							init];
	[fastImage_i	useRepresentation:(NXImageRep *)image_i];	
	return fastImage_i;
}

char *strupr(char *string)
{
	char *s = string;
	while (*string)
		*string++ = toupper(*string);
	return s;
}

