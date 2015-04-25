
#import <appkit/appkit.h>
#import "EditWorld.h"

extern	id	linepanel_i;

@interface LinePanel:Object
{
	id	p1_i;
	id	p2_i;
	id	special_i;
	id	pblock_i;
	id	twosided_i;
	id	sideradio_i;
	id	sideform_i;
	id	endform_i;
	
	id	window_i;
	
	worldline_t	baseline, oldline;
}

- menuTarget:sender;
- updateInspector: (BOOL)force;
- sideRadioTarget:sender;
- updateLineInspector;

- blockChanged: sender;
- twosideChanged: sender;
- specialChanged: sender;
- sideChanged: sender;

-baseLine: (worldline_t *)line;

@end
