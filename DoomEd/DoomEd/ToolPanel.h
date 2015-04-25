
#import <appkit/appkit.h>

typedef enum
{
	SELECT_TOOL = 0,
	POLY_TOOL,
	LINE_TOOL,
	ZOOMIN_TOOL,
	SLIDE_TOOL,
	GET_TOOL,
	THING_TOOL,
	LAUNCH_TOOL
} tool_t;

extern	id	toolpanel_i;

@interface ToolPanel:Object
{
    id	toolmatrix_i;
}

- toolChanged:sender;
- (tool_t)currentTool;
- changeTool:(int)which;

@end
