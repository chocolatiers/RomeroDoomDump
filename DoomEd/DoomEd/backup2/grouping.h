// grouping.h

#import "idfunctions.h"

int LineByPoint (NXPoint *pt, int *side);
void SelectPlaneLinesAround (NXPoint *pt);
void DrawConnectionLines (void);

extern	id		sectors;			// storage object of sectors
extern	boolean	sectorerror;		// if true, the save will not complete

void ConnectSectors (void);
