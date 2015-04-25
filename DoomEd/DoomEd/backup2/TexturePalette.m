#import	"DoomProject.h"
#import	"wadfiles.h"
#import	"TextureEdit.h"
#import	"TexturePalette.h"

id	texturePalette_i;

@implementation TexturePalette

- init
{
	window_i = NULL;
	texturePalette_i = self;
	selectedTexture = -1;

	allTextures = [[	Storage	alloc]
				initCount:		0
				elementSize:	sizeof(texpal_t)
				description:	NULL];
	
	return self;
}

- initTextures
{
	[self	createAllTextureImages];
	if ([allTextures	count])
		[self	selectTexture:0];
	return self;
}

- menuTarget:sender
{
	if (![doomproject_i loaded])
	{
		NXRunAlertPanel("Oops!",
						"There must be a project loaded before you even\n"
						"THINK about choosing textures!",
						"OK",NULL,NULL,NULL);
		return self;
	}
		
	if (!window_i)
	{
		NXPoint	p;
		NXRect	dvr,vf;
	
		[NXApp 
			loadNibSection:	"TexturePalette.nib"
			owner:			self
			withNames:		NO
		];

		[self	computePalViewSize];
		//
		// start textures at top
		//
		[texturePalScrView_i	getDocVisibleRect:&dvr];
		[texturePalView_i	getFrame:&vf];
		p.x = 0;
		p.y = dvr.size.height;// - vf.size.height;
		[texturePalScrView_i		scrollPoint:&p];
	}

	[window_i	makeKeyAndOrderFront:NULL];
	return self;
}

//
// create all the texture images for the palette
// NOTE: allTextures must have been created
//
- createAllTextureImages
{
	int	j;
	texpal_t	t;
	
	for (j = 0; j < numtextures; j++)
	{
		t = [self	createTextureImage:j];
		[allTextures	addElement:&t];
	}
	return self;
}

//
// create a texture image from all its patches for the palette
// NOTE: allTextures must have been created
//
- (texpal_t) createTextureImage:(int)which
{
	int	i;
	texpal_t	t;
	NXSize	s;

	s.width = textures[which].width;
	s.height = textures[which].height;
	NXSetRect(&t.r,0,0,0,0);
	t.r.size = s;
	strcpy(t.name,textures[which].name);
	t.image = [[NXImage alloc]
			initSize:	&s];
	[t.image	 useCacheWithDepth:NX_TwelveBitRGBDepth];
	[t.image	lockFocusOn:[t.image lastRepresentation]];
	
	NXSetColor(NXConvertRGBAToColor(1,0,0,1));
	NXRectFill(&t.r);

	for (i = 0; i < textures[which].patchcount; i++)
	{
		texpatch_t	p;
		
		p.patchInfo = textures[which].patches[i];
		p.patch = [textureEdit_i	getPatchImage:p.patchInfo.patchname];
		p.r.origin.x = p.patchInfo.originx;
		p.r.origin.y = (textures[which].height) - 
					(p.patch->r.size.height) - 
					(p.patchInfo.originy);
		p.r.size.width = p.patch->r.size.width;
		p.r.size.height = p.patch->r.size.height;
		[p.patch->image	composite:NX_SOVER toPoint:&p.r.origin];
	}
	[t.image	unlockFocus];
	return t;
}

//
// add/replace a texture image in palette
//
- storeTexture:(int)which
{
	texpal_t	*t,tex;
	
	if ((![allTextures	count]) ||
		(which > [allTextures	count] - 1))
			[allTextures	addElement:&tex];
	else
	{
		t = [allTextures	elementAt:which];
		[t->image	free];
	}
	
	tex = [self	createTextureImage:which];
	[allTextures	replaceElementAt:which with:&tex];

	[self	computePalViewSize];
	[texturePalScrView_i	display];
	return self;
}

//
// compute size of texture palette view from amount of texture images in allTextures
//
- computePalViewSize
{
	texpal_t	*t;
	int	count,maxwidth,x,y;
	NXSize	s,imagesize;
	
	maxwidth = 0;
	x = y = SPACING;
	count = [allTextures count] - 1;
	while (count >= 0)
	{
		t = [allTextures	elementAt:count];
		t->r.origin.x = x;
		t->r.origin.y = y;
		[t->image	getSize:&imagesize];
		if (imagesize.width > maxwidth)
			maxwidth = imagesize.width;
		y += imagesize.height + SPACING;
		count--;
	}
	
	s.width = maxwidth + SPACING*2;
	s.height = y;
	[texturePalView_i	sizeTo:s.width :s.height];
	return self;
}

//
// return * to texture image[which]
//
- (texpal_t *)getTexture:(int)which
{
	return [allTextures	elementAt:which];
}

- selectTexture:(int)val
{
	texpal_t *t;
	
	selectedTexture = val;
	t = [self	getTexture:val];
	[titleField_i	setStringValue:t->name];
	[widthField_i	setIntValue:t->r.size.width];
	[heightField_i	setIntValue:t->r.size.height];
	[texturePalScrView_i	display];
	return self;
}

- (int) currentSelection
{
	return selectedTexture;
}

- (int) getNumTextures
{
	return [allTextures	count];
}

- deleteTexture:sender
{
	return self;
}

@end
