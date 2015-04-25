#import <appkit/appkit.h>
#import "EditWorld.h"

#define CPOINTSIZE	7		// size for clicking
#define CPOINTDRAW	4		// size for drawing

#define LINENORMALLENGTH	6	// length of line segment side normal
#define THINGDRAWSIZE		32

extern	BOOL	linecross[9][9];

@interface MapView: View
{
	float		scale;
	
	int		gridsize;
}

- initFromEditWorld;

- (float)currentScale;
- getCurrentOrigin: (NXPoint *)worldorigin;

- scaleMenuTarget: sender;
- gridMenuTarget: sender;

- zoomFrom:(NXPoint *)origin toScale:(float)newscale;

- displayDirty: (NXRect const *)dirty;

- getPoint:	(NXPoint *)point  from: 	(NXEvent const *)event;
- getGridPoint:	(NXPoint *)point  from: 	(NXEvent const *)event;

- adjustFrameForOrigin: (NXPoint const *)org scale:(float)scl;
- adjustFrameForOrigin: (NXPoint const *)org;
- setOrigin: (NXPoint const *)org scale: (float)scl;
- setOrigin: (NXPoint const *)org;

@end

// import category definitions

#import "MapViewDraw.h"
#import "MapViewResp.h"

