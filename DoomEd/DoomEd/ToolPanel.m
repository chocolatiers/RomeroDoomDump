#import	"ThingPanel.h"
#import "ToolPanel.h"

id	toolpanel_i;

@implementation ToolPanel

- init
{
	toolpanel_i = self;
	return self;
}

- toolChanged:sender
{
	switch([self	currentTool])
	{
		case THING_TOOL:
			[thingpanel_i	pgmTarget];
		default:
			break;
	}
    return self;
}

- (tool_t)currentTool
{
	return [toolmatrix_i selectedRow];
}

- changeTool:(int)which
{
	[toolmatrix_i	selectCellAt:which :0];
	return self;
}


@end
