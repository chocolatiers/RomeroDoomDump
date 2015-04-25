
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
    return self;
}

- (tool_t)currentTool
{
	return TOOLCOLLUMNS*[toolmatrix_i selectedCol] + [toolmatrix_i selectedRow];
}

- showButton: sender
{
	printf ("button: %i\n",[sender intValue]);
	return self;
}

- newCoordX: (float)x Y:(float)y
{
	
	return self;
}


@end
