#import	"SectorEditor.h"
#import	"SectorPalette.h"

@implementation SectorPalette

id	sectorPalette_i;

- init
{
	window_i = NULL;
	sectorPalette_i = self;
	currentSector = -1;
	return self;
}

- menuTarget:sender
{
	if (!window_i)
	{
		[NXApp 
			loadNibSection:	"SectorPalette.nib"
			owner:			self
			withNames:		NO
		];
		
		[self	computeSectorDocView];
	}
	
	[window_i	setDelegate:self];
	[window_i	makeKeyAndOrderFront:NULL];
	
	return self;
}

- createSector
{
	sector_t	s;
	
	NXSetRect(&s.r,0,0,133,64);

	s.image = [[NXImage alloc]
			initSize:	&s.r.size];
	[s.image	 useCacheWithDepth:NX_TwelveBitRGBDepth];

	bzero(s.w.name,9);
	bzero(s.w.s.floorflat,9);
	bzero(s.w.s.ceilingflat,9);
	s.w.s.lightlevel = [sectorEdit_i	getLight];
	s.w.s.special = [sectorEdit_i	getSpecial];
	s.w.s.floorheight = 0;
	s.w.s.ceilingheight = 200;
	strcpy(s.w.s.floorflat,[sectorEdit_i	flatName:0]);
	strcpy(s.w.s.ceilingflat,[sectorEdit_i	flatName:0]);
	s.floor_flat = 0;
	s.ceiling_flat = 0;
	strcpy(s.w.name,"UNTITLED");

	[sectorEdit_i	setSectorTitle:s.w.name];
	[doomproject_i	newEnds:&s.w];	
	[sectors	addElement:&s];
	oldsector = s;
	
	[self		setCurrentSector:[sectors	count] - 1];
	[self		computeSectorDocView];
	[self		saveSector];
	[sectorScrPalView_i	display];
	return self;
}

- updateInfo
{
	sector_t	*s;
	
	s = [sectors	elementAt:currentSector];
	[cellTitle_i	setStringValue:s->w.name];
	[cellLight_i	setIntValue:s->w.s.lightlevel];
	[cellSpecial_i	setIntValue:s->w.s.special];
	[cellCheight_i	setIntValue:s->w.s.ceilingheight];
	[cellFheight_i	setIntValue:s->w.s.floorheight];
	[sectorScrPalView_i	display];
	return self;
}

- setCurrentSector:(int) what
{
	currentSector = what;
	[self	updateInfo];
	return self;
}

- (int) getCurrentSector
{
	return	currentSector;
}

- (int) getNumSectors
{
	return	[sectors	count];
}

- (sector_t *) getSector:(int) which
{
	return	[sectors	elementAt:which];
}

- saveSector
{
	int	cs;
	sector_t	*s;
	flat_t	*f;
	NXPoint	p;
	NXRect	r;

	cs = currentSector;
	if (cs < 0)
	{
		NXBeep();
		return self;
	}

	s = [sectors	elementAt:cs];
	[s->image	lockFocusOn:[s->image lastRepresentation]];
	
	p.x = p.y = 0;
	if (s->floor_flat < 0)
	{
		NXSetColor(NXConvertRGBToColor(1,0,0));
		NXSetRect(&r,p.x,p.y,64,64);
		NXRectFill(&r);
	}
	else
	{
		f = [sectorEdit_i	getFlat:s->floor_flat];
		[f->image		composite:NX_COPY	toPoint:&p];
	}
	
	p.x = 64 + 5;
	if (s->ceiling_flat < 0)
	{
		NXSetColor(NXConvertRGBToColor(1,0,0));
		NXSetRect(&r,p.x,p.y,64,64);
		NXRectFill(&r);
	}
	else
	{
		f = [sectorEdit_i	getFlat:s->ceiling_flat];
		[f->image		composite:NX_COPY	toPoint:&p];
	}
	
	[s->image	unlockFocus];
	s->w.s.lightlevel = [sectorEdit_i	getLight];
	s->w.s.special = [sectorEdit_i		getSpecial];
	[sectors	replaceElementAt:cs	with:s];
	[self		updateInfo];
	[self		computeSectorDocView];
	[sectorScrPalView_i	display];

	ends[cs] = s->w;
	
	return self;
}

//
// build
//
- buildSectors
{
	int	i,cf,ff;
	sector_t	s;
	flat_t	*f;
	NXPoint	p;
	
	sectors = [[ Storage	alloc]
				initCount:		0
				elementSize:	sizeof(sector_t)
				description:	NULL];
				
	for (i = 0; i < numends; i++)
	{
		NXSetRect(&s.r,0,0,133,64);

		s.w = ends[i];
		s.image = [[NXImage alloc]
				initSize:	&s.r.size];
		[s.image	 useCacheWithDepth:NX_TwelveBitRGBDepth];
		[s.image	lockFocusOn:[s.image lastRepresentation]];
		
		cf = [sectorEdit_i	findFlat:ends[i].s.ceilingflat];
		if (cf < 0)
			return [self	error:"Can't find ceilingflat!"];
		ff = [sectorEdit_i	findFlat:ends[i].s.floorflat];
		if (ff < 0)
			return [self	error:"Can't find floorflat!"];
		
		s.floor_flat = ff;
		s.ceiling_flat = cf;
		p.y = p.x = 0;
		f = [sectorEdit_i	getFlat:ff];
		[f->image	composite:NX_COPY	toPoint:&p];
		p.x = 64 + 5;
		f = [sectorEdit_i	getFlat:cf];
		[f->image	composite:NX_COPY	toPoint:&p];
				
		[s.image	unlockFocus];
		[sectors	addElement:&s];
	}
	
	return self;
}

//
// set coords for all sectors in the sectorView
//
- computeSectorDocView
{
	NXRect	dvr;
	int	i,y,max;
	sector_t	*s;
	
	[sectorScrPalView_i	getDocVisibleRect:&dvr];
	max = [self		getNumSectors];
	y = SPACING;
	
	for (i = 0; i < max; i++)
	{
		s = [self	getSector:i];
		s->r.origin.x = SPACING;
		s->r.origin.y = y;
		y += s->r.size.height + SPACING;
	}
	
	[sectorPalView_i	sizeTo:dvr.size.width	:y];
	return self;
}

@end
