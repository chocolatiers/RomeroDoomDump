#import	"TextureEdit.h"
#import	"Wadfile.h"
#import	"EditWorld.h"
#import	"lbmfunctions.h"
#import	"SectorEditor.h"
#import	"SpecialList.h"
#import	"LinePanel.h"
#import	"FlatsView.h"
#import	"DoomProject.h"

@implementation SectorEditor

id	sectorEdit_i;

- init
{
	window_i = NULL;
	sectorEdit_i = self;
	currentFlat = -1;
	specialPanel_i = [[[[SpecialList	alloc]
					setSpecialTitle:"Sector Editor - Specials"]
					setFrameName:"SectorSpecialPanel"]
					setDelegate:self];
	return self;
}

- saveFrame
{
	[specialPanel_i	saveFrame];
	if (window_i)
		[window_i	saveFrameUsingName:"SectorEditor"];
	return self;
}

- setKey:sender
{
	[[editworld_i	getMainWindow] makeKeyAndOrderFront:NULL];
	return self;
}

- pgmTarget
{
	if (![doomproject_i loaded])
	{
		NXRunAlertPanel("Oops!",
						"There must be a project loaded before you even\n"
						"THINK about editing sectors!",
						"OK",NULL,NULL,NULL);
		return self;
	}
	
	if (!window_i)
	{
		[self	menuTarget:NULL];
		return self;
	}
	
	[window_i	orderFront:NULL];
	return self;
}

- setupEditor
{
	[self	computeFlatDocView];
	
	[cheightfield_i		setIntValue:200];
	[fheightfield_i		setIntValue:0];
	ceiling_flat = floor_flat = 0;
	[special_i			setIntValue:0];
	[tag_i			setIntValue:0];
	[lightLevel_i		setIntValue:0];
	sector.floorheight = 0;
	sector.ceilingheight = 200;
	strcpy(sector.floorflat,[self	getFloorFlat]->name);
	strcpy(sector.ceilingflat,[self	getCeilingFlat]->name);
	sector.lightlevel = 0;
	sector.special = 0;
	sector.tag = 0;
	
	[window_i	setFrameUsingName:"SectorEditor"];
	[self	setCurrentFlat:0];
	return self;
}

- menuTarget:sender
{
	if (![doomproject_i loaded])
	{
		NXRunAlertPanel("Oops!",
						"There must be a project loaded before you even\n"
						"THINK about editing sectors!",
						"OK",NULL,NULL,NULL);
		return self;
	}
	
	if (!window_i)
	{
		[NXApp 
			loadNibSection:	"SectorEditor.nib"
			owner:			self
			withNames:		NO
		];
		[self	setupEditor];
		[window_i	setAvoidsActivation:YES];
	}
	
	//
	// make sure flats are loaded before window inits
	//	
	[window_i	setDelegate:self];
	[window_i	orderFront:NULL];
	return self;
}

- windowDidMiniaturize:sender
{
	[sender	setMiniwindowIcon:"DoomEd"];
	[sender	setMiniwindowTitle:"SectorEdit"];
	return self;
}

//============================================================
//
//	Clicked on little arrow adjusters
//
//============================================================
- ceilingAdjust:sender
{
	[cheightfield_i	setIntValue:[cheightfield_i	intValue] +
			[[sender	selectedCell]	tag]];
	[self	CorFheightChanged:NULL];
	return self;
}

- floorAdjust:sender
{
	[fheightfield_i	setIntValue:[fheightfield_i	intValue] +
			[[sender	selectedCell]	tag]];
	[self	CorFheightChanged:NULL];
	return self;
}

//============================================================
//
//	Get tag value from line panel tag field
//
//============================================================
- getTagValue:sender
{
	[tag_i	setIntValue:[linepanel_i	getTagValue]];
	[self	setKey:NULL];
	
	return self;
}

//============================================================
//
//	Light level arrow clicks
//
//============================================================
- lightLevelDown:sender
{
	int	level;
	
	level = [lightLevel_i	intValue];
	if (level == 255)
		level++;
	level = (level -16) & -16;
	if (level < 0)
		level = 0;
	[lightLevel_i	setIntValue:level];
	[lightSlider_i	setIntValue:level];
	[self	setKey:NULL];
	
	return self;
}

- lightLevelUp:sender
{
	int	level;
	
	level = [lightLevel_i	intValue];
	level = (level +16) & -16;
	if (level > 255)
		level = 255;
	[lightLevel_i	setIntValue:level];
	[lightSlider_i	setIntValue:level];
	[self	setKey:NULL];

	return self;
}

//============================================================
//
//	Set all Sector Editor info to what's being passed
//
//============================================================
- setSector:(sectordef_t *) s
{
	int	val;
	flat_t	*f;
	
	if (!s->floorflat[0] || !s->ceilingflat[0] ||
		s->floorflat[0] =='-' || s->ceilingflat[0]=='-')
	{
		s->floorheight = 0;
		s->ceilingheight = 72;
		f = [flatImages	elementAt:0];
		strcpy(s->floorflat,f->name);
		strcpy(s->ceilingflat,f->name);
		s->lightlevel = 255;
		s->special = s->tag = 0;
	}
	
	[self	pgmTarget];

	sector = *s;
	floor_flat = [self	findFlat:sector.floorflat];
	ceiling_flat = [self	findFlat:sector.ceilingflat];
	
	if (floor_flat < 0)
	{
		f = [flatImages elementAt:0];
		strcpy(sector.floorflat,f->name);
		floor_flat = 0;
	}
	
	if (ceiling_flat < 0)
	{
		f = [flatImages elementAt:0];
		strcpy(sector.ceilingflat,f->name);
		ceiling_flat = 0;
	}
	
	val = sector.lightlevel;
	if (val != 255)
		val &= -16;
	[lightLevel_i		setIntValue:val];
	[lightSlider_i		setIntValue:val];
	[special_i			setIntValue:sector.special];
	[tag_i				setIntValue:sector.tag];
	[cheightfield_i		setIntValue:sector.ceilingheight];
	[fheightfield_i		setIntValue:sector.floorheight];
	[cflatname_i		setStringValue:sector.ceilingflat];
	[fflatname_i		setStringValue:sector.floorflat];
	[totalHeight_i		setIntValue:sector.ceilingheight - sector.floorheight];
	[specialPanel_i		setSpecial:sector.special];

	[sectorEditView_i	display];
	return self;
}

- lightChanged:sender
{
	int	val;
	val = [lightLevel_i	intValue];
	if (val != 255)
		val &= -16;
	[lightLevel_i	setIntValue:val];
	[lightSlider_i	setIntValue:val];
	[self	setKey:NULL];
	return self;
}

- lightSliderChanged:sender
{
	int	val;
	val = [lightSlider_i	intValue];
	if (val != 255)
		val &= -16;
	[lightLevel_i	setIntValue:val];
	[lightSlider_i	setIntValue:val];
	[self	setKey:NULL];
	return self;
}

- selectFloor
{
	[floorAndCeiling_i	selectCellAt:0 :1];
	return self;
}

- selectCeiling
{
	[floorAndCeiling_i	selectCellAt:0 :0];
	return self;
}

- setCeiling:(int) what
{
	[cheightfield_i		setIntValue:what];
	[totalHeight_i		setIntValue:what - [fheightfield_i  intValue]];
	[self	setKey:NULL];

	return self;
}

- setFloor:(int) what
{
	[fheightfield_i		setIntValue:what];
	[totalHeight_i		setIntValue:[cheightfield_i  intValue] - what];
	[self	setKey:NULL];

	return self;
}

//============================================================
//
//	Typed value in Total Height field.
//	Floor height remains the same; adjust ceilingheight.
//
//============================================================
- totalHeightAdjust:sender
{
	int	val;
	val = [fheightfield_i		intValue];
	val += [sender		intValue];
	val &= -8;
	[self		setCeiling:val];
	sector.ceilingheight = val;
	[sectorEditView_i	display];
	[self	setKey:NULL];
	
	return self;
}

//============================================================
//
//	Ceiling or Floor height changed -- clip and modify totalHeight
//
//============================================================
- CorFheightChanged:sender
{
	int	val;
	
	val = [cheightfield_i	intValue];
	val &= -8;
	if (val < [fheightfield_i	intValue])
		val = [fheightfield_i	intValue];
	[cheightfield_i		setIntValue:val];
	sector.ceilingheight = val;

	val = [fheightfield_i		intValue];
	val &= -8;
	if (val > [cheightfield_i	intValue])
		val = [cheightfield_i	intValue];
	[fheightfield_i		setIntValue:val];
	sector.floorheight = val;
	[sectorEditView_i	display];
	[totalHeight_i		setIntValue:sector.ceilingheight - sector.floorheight];
	[self	setKey:NULL];
	
	return self;
}

//============================================================
//
//	Find the flat in the palette designated by floor/ceiling radio button
//
//============================================================
- locateFlat:sender
{
	int	flat;
	flat_t	*f;
	NXRect	r;
	
	if ([ceiling_i	intValue])
		flat = ceiling_flat;
	else
		flat = floor_flat;
		
	if (flat < 0)
	{
		NXBeep();
		return self;
	}
	
	[self	selectFlat:flat];
	f = [flatImages	elementAt:flat];
	r = f->r;
	r.origin.x -= SPACING;
	r.origin.y -= SPACING;
	r.size.width += SPACING*2;
	r.size.height += SPACING*2;
	[flatPalView_i		scrollRectToVisible:&r];
	[flatPalView_i		display];
	[self	setKey:NULL];
	
	return self;
}

//============================================================
//
//	Return all information for sector - EXTERNAL INFO
//
//============================================================
- (sectordef_t *) getSector
{
	sector.lightlevel = [lightLevel_i	intValue];
	sector.special = [special_i	intValue];
	sector.tag = [tag_i	intValue];
	sector.ceilingheight = [cheightfield_i	intValue];
	sector.floorheight = [fheightfield_i	intValue];
	strcpy(sector.floorflat,[self	getFloorFlat]->name);
	strcpy(sector.ceilingflat,[self	getCeilingFlat]->name);

	return &sector;
}

//==========================================================
//
//	Get rid of all flats and their images
//
//==========================================================
- dumpAllFlats
{
	int			i, max;
	flat_t		*p;
	id			panel;
	
	panel = NXGetAlertPanel("Wait...","Dumping texture patches.",
		NULL,NULL,NULL);
	[panel	orderFront:NULL];
	NXPing();
	
	max = [ flatImages	count ];
	for (i = 0; i < max; i++)
	{
		p = [ flatImages	elementAt: i ];
		[ p->image	free ];
	}
	
	[ flatImages	empty ];
	[panel	orderOut:NULL];
	NXFreeAlertPanel(panel);
	
	return self;
}

- emptySpecialList
{
	[ specialPanel_i	empty ];
	return self;
}

//============================================================
//
//	Load in all the flats for the palette
//	NOTE: called at start of project
//
//============================================================
- (int)loadFlats
{
	int		flatStart;
	int		flatEnd;
	int		i;
	unsigned short	shortpal[256];
	byte 	*palLBM;
	byte 	*flat;
	flat_t	f;
	int		windex;
	char	start[10];
	char	end[10];
	char	string[80];

	//
	//	Get palette and convert to 16-bit
	//
	palLBM = [wadfile_i	loadLumpNamed:"playpal"];
	if (palLBM == NULL)
		IO_Error ("Need to have 'playpal' palette in .WAD file!");
	LBMpaletteTo16 (palLBM, shortpal);

	flatImages = [[Storage	alloc]
				initCount:		0
				elementSize:	sizeof(flat_t)
				description:	NULL];
	
	NXSetRect(&f.r,0,0,0,0);
	
	windex = 0;
	do
	{
		sprintf(string,"Loading flat set #%d for Sector Editor.",windex+1);
		[doomproject_i	initThermo:"One moment..."  message:string];
		
		//
		// get inclusive lump #'s for patches
		//
		sprintf( start,"f%d_start",windex+1);
		sprintf( end, "f%d_end",windex+1);
		flatStart = [wadfile_i	lumpNamed:start] + 1;
		flatEnd = [wadfile_i		lumpNamed:end];
	
		if  (flatStart == -1 || flatEnd == -1 )
		{
			if ( !windex )
				IO_Error("You need to relink your WAD file "
					"-- I can't find any flats!");
			else
			{
				windex = -1;
				continue;
			}
		}
		
		for (i = flatStart; i < flatEnd; i++)
		{
			[doomproject_i	updateThermo:i-flatStart max:flatEnd-flatStart];
			//
			// load raw 64*64 flat and convert to an NXImage
			//
			flat = [wadfile_i	loadLump:i];
			f.WADindex = windex;
			f.image = flatToImage(flat,shortpal);
			f.r.size.width = 64;
			f.r.size.height = 64;
			strcpy(f.name,[wadfile_i	lumpname:i]);
			f.name[8] = 0;
			[flatImages	addElement:&f];
			free(flat);
		}
		windex++;
		
	} while (windex >= 0);
	
	free(palLBM);
	[doomproject_i	closeThermo];
	
	return 0;
}		

//============================================================
//
//	Set coords for all flats in the flatView -- setup flatView
//
//============================================================
- computeFlatDocView
{
	NXRect	dvr;
	int		i,x,y,max;
	flat_t	*f;
	int		maxwidth;
	NXPoint	p;
	int		maxwindex;
	char	string[32];
	
	[flatPalView_i	dumpDividers];
	[flatScrPalView_i	getDocVisibleRect:&dvr];
	max = [flatImages	count];
	maxwidth = FLATSIZE*3 + SPACING*3;

	//
	//	Calculate the size of docView we're gonna need... 
	//
	x = y = SPACING;
	maxwindex = 0;
	for (i = 0; i < max; i++)
	{
		f = [flatImages	elementAt:i];
		if (f->WADindex > maxwindex)
		{
			maxwindex = f->WADindex;
			x = SPACING;
			y += FLATSIZE + (FLATSIZE/2) + SPACING*2;
		}
		
		if (x > maxwidth)
		{
			x = SPACING;
			y += FLATSIZE + SPACING;
		}
		x += FLATSIZE + SPACING;
	}
	
	[flatPalView_i	sizeTo:dvr.size.width	:y + FLATSIZE + SPACING];
	p.x = 0;
	p.y = y + FLATSIZE*2 + SPACING*2;
	x = SPACING;

	//
	//	The docView has been resized. Now go and reorder all
	//	the flats from top to bottom...
	//
	maxwindex = 0;
	for (i = 0; i < max; i++)
	{
		f = [flatImages	elementAt:i];
		if (f->WADindex > maxwindex)
		{
			maxwindex = f->WADindex;
			x = SPACING;
			y -= FLATSIZE/2 + SPACING;
			sprintf ( string, "Flat Set #%d", maxwindex+1 );
			[flatPalView_i	addDividerX:	x
						Y: y
						String: string ];
			y -= FLATSIZE + SPACING;
		}
		if (x > maxwidth )
		{
			x = SPACING;
			y -= FLATSIZE + SPACING;
		}
		f->r.origin.x = x;
		f->r.origin.y = y;
		x += FLATSIZE + SPACING;
	}
	
	[flatPalView_i	scrollPoint:&p ];
	[flatScrPalView_i	display];

	return self;
}

- (char *)flatName:(int) flat
{
	flat_t	*f;
	f = [flatImages	elementAt:flat];
	if (f == NULL)
		return NULL;
	return	f->name;
}

- (int) findFlat:(const char *)name
{
	int	max,i;
	flat_t	*f;
	
	max = [flatImages	count];
	for (i = 0;i < max; i++)
	{
		f = [flatImages	elementAt:i];
		if (!strcasecmp(f->name,name))
			return i;
	}
	return -1;
}

- (flat_t *) getCeilingFlat
{
	return	[flatImages	elementAt:ceiling_flat];
}

- (flat_t *) getFloorFlat
{
	return	[flatImages	elementAt:floor_flat];
}

- selectFlat:(int) which
{
	flat_t	*f;
	
	currentFlat = which;
	f = [flatImages	elementAt:currentFlat];
	
	if ([ceiling_i	intValue])
	{
		ceiling_flat = which;
		strncpy(sector.ceilingflat,f->name,9);
		[cflatname_i	setStringValue:sector.ceilingflat];
		[curFlat_i		setStringValue:sector.ceilingflat];
	}
	else
	{
		floor_flat = which;
		strncpy(sector.floorflat,f->name,9);
		[fflatname_i	setStringValue:sector.floorflat];
		[curFlat_i		setStringValue:sector.ceilingflat];
	}
	
	[flatPalView_i	scrollRectToVisible:&f->r];
	[flatScrPalView_i	display];
	[sectorEditView_i	display];
	[self	setKey:NULL];
	return self;
}

- setCurrentFlat:(int)which
{
	flat_t	*f;
	NXRect	r;
	
	currentFlat = which;
	[curFlat_i		setStringValue:[self  flatName:which] ];
	f = [flatImages	elementAt:which];
	r = f->r;
	r.origin.x -= SPACING;
	r.origin.y -= SPACING;
	r.size.width += SPACING*2;
	r.size.height += SPACING*2;
	[flatPalView_i		scrollRectToVisible:&r];
	[flatScrPalView_i	display];
	
	return self;
}

- (int) getCurrentFlat
{
	return	currentFlat;
}

- (int) getNumFlats
{
	return	[flatImages	count];
}

- (flat_t *) getFlat:(int) which
{
	return	[flatImages	elementAt:which];
}

//=================================================================
//
//	Search for sector that matches TAG field
//
//=================================================================
- searchForTaggedSector:sender
{
	int		tag, i, found;
	
	tag = [tag_i	intValue];
	found = 0;
	
	for (i = 0; i < numlines; i++)
		if (	(lines[i].side[0].ends.tag == tag) ||
			(lines[i].side[1].ends.tag == tag)  )
		{
			[editworld_i	selectLine:i];
			found = 1;
		}

	if (!found)
		NXBeep ();
	else
		[editworld_i	updateWindows];
		
	[self	setKey:NULL];
	return self;
}

//=================================================================
//
//	Search for line that matches TAG field
//
//=================================================================
- searchForTaggedLine:sender
{
	int		tag, i, found;
	
	tag = [tag_i	intValue];
	found = 0;
	
	for (i = 0; i < numlines; i++)
		if ( lines[i].tag == tag)
		{
			[editworld_i	selectLine:i];
			found = 1;
		}

	if (!found)
		NXBeep ();
	else
		[editworld_i	updateWindows];
		
	[self	setKey:NULL];
	return self;
}

- error:(const char *)string
{
	NXRunAlertPanel("Oops!",string,"OK",NULL,NULL,NULL);
	return self;
}

//
// user resized the Sector Editor window.
// change the size of the flats/sector palettes.
//
- windowDidResize:sender
{
	[self		computeFlatDocView];
	[window_i	display];
	return self;
}

- specialChosen:(int)value
{
	[special_i		setIntValue:value];
	return self;
}

- updateSectorSpecialsDSP:(FILE *)stream
{
	[specialPanel_i	updateSpecialsDSP:stream];
	return self;
}

- activateSpecialList:sender
{
	[specialPanel_i	displayPanel];
	return self;
}

@end

//=================================================================
//
//	Convert a raw 64x64 to an NXImage without an alpha channel
//
//=================================================================
id	flatToImage(byte *rawData, unsigned short *shortpal) //byte const *lbmpalette)
{
	short		*dest_p;
	NXImageRep *image_i;
	id			fastImage_i;
	unsigned		i;

	//
	// make an NXimage to hold the data
	//
	image_i = [[NXBitmapImageRep alloc]
		initData:			NULL 
		pixelsWide:		64 
		pixelsHigh:		64
		bitsPerSample:	4
		samplesPerPixel:	3 
		hasAlpha:		NO
		isPlanar:			NO 
		colorSpace:		NX_RGBColorSpace 
		bytesPerRow:		128
		bitsPerPixel: 		16
	];

	if (!image_i)
		return nil;
				
	//
	// translate the picture
	//
	 (unsigned char *)dest_p =[(NXBitmapImageRep *)image_i data];
	memset(dest_p,0,64 * 64 * sizeof(short));
	
	for (i = 0;i < 64*64; i++)
		*(dest_p++) = shortpal[*(rawData++)];

	fastImage_i = [[NXImage	alloc]
							init];
	[fastImage_i	useRepresentation:(NXImageRep *)image_i];	
	return fastImage_i;
}
