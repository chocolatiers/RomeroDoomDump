
#import <appkit/appkit.h>

#define TOOLCOLLUMNS	4

typedef enum
{
	SELECT_TOOL = 0,
	POLY_TOOL,
	LINE_TOOL,
	ZOOMIN_TOOL,
	SLIDE_TOOL,
	ENDS_TOOL,
	THING_TOOL
} tool_t;

extern	id	toolpanel_i;

@interface ToolPanel:Object
{
    id	toolmatrix_i;
	id	xcoord_i;
	id	ycoord_i;
	
}

- toolChanged:sender;
- showButton: sender;

- newCoordX: (float)x Y:(float)y;

- (tool_t)currentTool;

@end
