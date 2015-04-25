
#import <appkit/appkit.h>
#import "EditWorld.h"

extern	id	thingpanel_i;

@interface ThingPanel:Object
{
    id	fields_i;
    id	window_i;
	
	worldthing_t	basething, oldthing;
}

- menuTarget:sender;
- formTarget: sender;
- updateInspector: (BOOL)force;
- updateThingInspector;

@end
