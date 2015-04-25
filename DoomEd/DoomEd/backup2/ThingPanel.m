#import "MapWindow.h"
#import "EditWorld.h"
#import "ThingPanel.h"

id	thingpanel_i;

@implementation ThingPanel

/*
=====================
=
= init
=
=====================
*/

- init
{
	thingpanel_i = self;
	window_i = NULL;		// until nib is loaded
	
	return self;
}



/*
==============
=
= menuTarget:
=
==============
*/

- menuTarget:sender
{
	if (![editworld_i loaded])
	{
		NXRunAlertPanel ("Error","No world loaded",NULL,NULL,NULL);
		return self;
	}
		
	if (!window_i)
	{
		[NXApp 
			loadNibSection:	"thing.nib"
			owner:			self
			withNames:		NO
		];
		
	}

	[window_i orderFront:self];

	return self;
}


/*
==============
=
= updateInspector
=
= call with force == YES to update into a window while it is off screen, otherwise
= no updating is done if not visible
=
==============
*/

- updateInspector: (BOOL)force
{
	if (!force && ![window_i isVisible])
		return self;

	[window_i disableFlushWindow];
	
	[fields_i setIntValue: basething.angle at: 0];
	[fields_i setIntValue: basething.type at: 1];
	[fields_i setIntValue: basething.options at: 2];
	
	[window_i reenableFlushWindow];
	[window_i flushWindow];
	
	return self;
}

/*
==============
=
= formTarget:
=
= The user has edited something in a form cell
=
==============
*/

- formTarget: sender
{
	int			i;
	worldthing_t	*thing;
	
	basething.angle = [fields_i intValueAt: 0];
	basething.type = [fields_i intValueAt: 1];
	basething.options = [fields_i intValueAt: 2];

	thing = &things[0];
	for (i=0 ; i<numthings ; i++, thing++)
		if (thing->selected > 0)
		{
			thing->angle = basething.angle;
			thing->type = basething.type;
			thing->options = basething.options;
			[editworld_i changeThing: i to: thing];
		}
		
	
	return self;
}


/*
==============
=
= updateThingInspector
=
==============
*/

- updateThingInspector
{
	int			i;
	worldthing_t	*thing;
	
	thing = &things[0];
	for (i=0 ; i<numthings ; i++, thing++)
		if (thing->selected > 0)
		{
			basething = *thing;
			break;
		}
		
	if (bcmp (&basething, &oldthing, sizeof(basething)) )
	{
		memcpy (&oldthing, &basething, sizeof(oldthing));
		[self updateInspector: NO];
	}
			
	return self;
}	


/*
===================
=
= windowDidUpdate:
=
===================
*/

- windowDidUpdate:sender
{
	[self updateInspector: YES];
		
	return self;
}


@end
