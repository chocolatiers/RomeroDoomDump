#import	"SectorEditor.h"
#import <appkit/appkit.h>

extern	id	sectorPalette_i;

@interface SectorPalette:Object
{
	id	window_i;
	id	sectorScrPalView_i;
	id	sectorPalView_i;
	
	id	cellTitle_i;
	id	cellLight_i;
	id	cellSpecial_i;
	id	cellFheight_i;
	id	cellCheight_i;
	
	int	currentSector;
	id	sectors;
	sector_t	oldsector;
}

- menuTarget:sender;

- updateInfo;
- buildSectors;
- createSector;
- saveSector;
- setCurrentSector:(int) what;
- (int) getCurrentSector;
- (int) getNumSectors;
- (sector_t *) getSector:(int) which;

- computeSectorDocView;

@end
