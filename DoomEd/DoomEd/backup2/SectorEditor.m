#import	"TextureEdit.h"
#import	"Wadfile.h"
#import	"lbmfunctions.h"
#import	"SectorPalette.h"
#import	"SectorEditor.h"

@implementation SectorEditor

id	sectorEdit_i;

- init
{
	window_i = NULL;
	sectorEdit_i = self;
	currentFlat = -1;
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

		[self	computeFlatDocView];
	}
	
	//
	// make sure patches are loaded before window inits
	//	
	[window_i	setDelegate:self];
	[window_i	makeKeyAndOrderFront:self];
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

- setSectorTitle:(char *)string
{
	[title_i	setStringValue:string];
	return self;
}

- titleChanged:sender
{
	char		string[9];
	sector_t	*s;
	int	cs;
	
	cs = [sectorPalette_i	getCurrentSector];
	if (cs < 0)
	{
		[title_i	setStringValue:""];
		return self;
	}
	s = [sectorPalette_i		getSector:cs];
	
	bzero(string,9);
	strncpy(string,[title_i	stringValue],8);
	strupr(string);
	[title_i	setStringValue:string];
	strncpy(s->w.name,[title_i	stringValue],8);
	return self;
}

- setCeiling:(int) what
{
	[cheightfield_i		setIntValue:what];
	return self;
}

- setFloor:(int) what
{
	[fheightfield_i		setIntValue:what];
	return self;
}

- CorFheightChanged:sender
{
	int	cs, val;
	sector_t	*s;
	
	cs = [sectorPalette_i	getCurrentSector];
	s = [sectorPalette_i		getSector:cs];
	val = [cheightfield_i	intValue];
	if (val < 0)
		val = 0;
	if (val > 200)
		val = 200;
	if (val < [fheightfield_i	intValue])
		val = [fheightfield_i	intValue];
	s->w.s.ceilingheight = val;

	val = [fheightfield_i		intValue];
	if (val < 0)
		val = 0;
	if (val > 200)
		val = 200;
	s->w.s.floorheight = val;
	[sectorEditView_i	display];
	
	return self;
}

- createSector:sender
{
	[sectorPalette_i	createSector];
	[sectorEditView_i	display];
	return self;
}

//
// Save the sector in the palette
// Here is where we check for incomplete data
//
- saveSector:sender
{
	sector_t	*s, *news;
	int	ns, cs, i;
	
	s = [sectorPalette_i		getSector:[sectorPalette_i getCurrentSector]];	
	if (!s->w.name[0])
	{
		NXBeep();
		NXRunAlertPanel("Oops!","You need to name your new sector!","OK",
						NULL,NULL,NULL);
		return self;
	}
	
	if (s->floor_flat < 0 || s->ceiling_flat < 0)
	{
		NXBeep();
		NXRunAlertPanel("Oops!","You need to assign both ceiling & floor flats!","OK",
						NULL,NULL,NULL);
		return self;
	}
	
	cs = [sectorPalette_i	getCurrentSector];
	ns = [sectorPalette_i	getNumSectors];
	for (i = 0;i < ns; i++)
	{
		news = [sectorPalette_i	getSector:i];
		if (!strcmp(s->w.name,news->w.name) && i!=cs)
		{
			NXBeep();
			NXRunAlertPanel("Oops!","The current sector has the same name as another"
							"sector in the palette!","OK",NULL,NULL,NULL);
			return self;
		}
	}
	
	[sectorPalette_i	saveSector];
	return self;
}

- (int) getLight
{
	return	[lightLevel_i	intValue];
}

- (int) getSpecial
{
	return	[special_i		intValue];
}

//
// Change to a different sector
//
- changeSector:(int) which
{
	sector_t	*s;
	
	[sectorPalette_i	setCurrentSector:which];
	s = [sectorPalette_i		getSector:which];
	[lightLevel_i	setIntValue:s->w.s.lightlevel];
	[special_i		setIntValue:s->w.s.special];
	[cheightfield_i	setIntValue:s->w.s.ceilingheight];
	[fheightfield_i	setIntValue:s->w.s.floorheight];
	[title_i		setStringValue:s->w.name];
	[sectorEditView_i	display];
	
	return self;
}

//
// load in all the flats for the palette
// NOTE: called at start of project
//
- (int)loadFlats
{
	int	flatStart, flatEnd, i;
	byte *palLBM;
	byte *flat;
	flat_t	f;

	palLBM = [wadfile_i	loadLumpNamed:"playpal"];
	//
	// get inclusive lump #'s for patches
	//
	flatStart = [wadfile_i	lumpNamed:"f_start"] + 1;
	flatEnd = [wadfile_i	lumpNamed:"f_end"];

	if (flatStart == -1)
		IO_Error("There are NO FLAT PLANES in the current .WAD file!  "
						"You cannot edit/create sectors without them!");
	
	flatImages = [[Storage	alloc]
				initCount:		0
				elementSize:	sizeof(flat_t)
				description:	NULL];
	
	NXSetRect(&f.r,0,0,0,0);
	for (i = flatStart; i < flatEnd; i++)
	{
		//
		// load raw 64*64 flat and convert to an NXImage
		//
		flat = [wadfile_i	loadLump:i];
		f.image = flatToImage(flat,palLBM);
		f.r.size.width = 64;
		f.r.size.height = 64;
		strcpy(f.name,[wadfile_i	lumpname:i]);
		[flatImages	addElement:&f];
		free(flat);
	}
	
	free(palLBM);
	return 0;
}		

//
// set coords for all flats in the flatView
//
- computeFlatDocView
{
	NXRect	dvr;
	int	i,x,y,max;
	flat_t	*f;
	
	[flatScrPalView_i	getDocVisibleRect:&dvr];
	max = [flatImages	count];
	x = y = SPACING;
	
	for (i = 0; i < max; i++)
	{
		f = [flatImages	elementAt:i];
		if (x > dvr.size.width - (f->r.size.width + SPACING))
		{
			x = SPACING;
			y += 64 + SPACING;
		}
		f->r.origin.x = x;
		f->r.origin.y = y;
		x += f->r.size.width + SPACING;
	}
	
	y += 64 + SPACING;
	[flatPalView_i	sizeTo:dvr.size.width	:y];
	return self;
}

- (char *)flatName:(int) flat
{
	flat_t	*f;
	f = [flatImages	elementAt:flat];
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
		if (!strcmp(f->name,name))
			return i;
	}
	return -1;
}

- selectFlat:(int) which
{
	sector_t	*s;
	flat_t	*f;
	
	if ([sectorPalette_i	getCurrentSector] < 0)
	{
		NXBeep();
		return self;
	}
	
	currentFlat = which;
	f = [flatImages	elementAt:currentFlat];
	s = [sectorPalette_i		getSector:[sectorPalette_i getCurrentSector]];
	
	if ([ceiling_i	intValue])
	{
		s->ceiling_flat = which;
		strncpy(s->w.s.ceilingflat,f->name,9);
	}
	else
	{
		s->floor_flat = which;
		strncpy(s->w.s.floorflat,f->name,9);
	}
	
	[flatScrPalView_i	display];
	[sectorEditView_i	display];
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

- addToPalette:sender
{
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

@end

//
// convert a raw 64x64 to an NXImage without an alpha channel
//
id	flatToImage(byte *rawData,byte const *lbmpalette)
{
	short		*dest_p;
	NXImageRep *image_i;
	id			fastImage_i;
	unsigned short	shortpal[256];
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
	LBMpaletteTo16 (lbmpalette, shortpal);
	 (unsigned char *)dest_p =[(NXBitmapImageRep *)image_i data];
	memset(dest_p,0,64 * 64 * sizeof(short));
	
	for (i = 0;i < 64*64; i++)
		*(dest_p++) = shortpal[*(rawData++)];

	fastImage_i = [[NXImage	alloc]
							init];
	[fastImage_i	useRepresentation:(NXImageRep *)image_i];	
	return fastImage_i;
}
