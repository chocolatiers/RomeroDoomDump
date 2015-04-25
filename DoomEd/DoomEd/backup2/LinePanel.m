#import "idfunctions.h"
#import "LinePanel.h"

id	linepanel_i;

@implementation LinePanel

/*
=====================
=
= init
=
=====================
*/

- init
{
	linepanel_i = self;
	window_i = NULL;		// until nib is loaded

	memset (&baseline, 0, sizeof(baseline));
	baseline.flags = ML_BLOCKMOVE;
	baseline.p1 = baseline.p2 = -1;
	baseline.side[0].midheight = 80;
	strcpy (baseline.side[0].toptexture, "T1");
	strcpy (baseline.side[0].bottomtexture, "T1");
	strcpy (baseline.side[0].midtexture, "T1");
	baseline.side[0].ends.floorheight = 0;
	baseline.side[0].ends.ceilingheight = 80;
	strcpy (baseline.side[0].ends.floorflat, "FLAT1");
	strcpy (baseline.side[0].ends.ceilingflat, "FLAT2");
	
	memcpy (&baseline.side[1], &baseline.side[0], sizeof(baseline.side[0]));
	
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
		NXRunAlertPanel ("Error","No map loaded",NULL,NULL,NULL);
		return self;
	}
		
	if (!window_i)
	{
		[NXApp 
			loadNibSection:	"line.nib"
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
= sideRadioTarget:
=
==============
*/

- sideRadioTarget:sender
{
	[self updateInspector: NO];
	return self;
}



/*
==================
=
= getSide:
=
= Sets variables in side from a form object
==================
*/

- getSide: (worldside_t *)side
{
	side->flags = [sideform_i intValueAt: 0];
	side->firstcollumn = [sideform_i intValueAt: 1];
	strncpy (side->toptexture, [sideform_i stringValueAt: 2], 9);
	strncpy (side->midtexture, [sideform_i stringValueAt: 3], 9);
	strncpy (side->bottomtexture, [sideform_i stringValueAt: 4], 9);
	side->midheight = [sideform_i intValueAt: 5];

	side->ends.floorheight = [endform_i intValueAt: 0];
	side->ends.ceilingheight = [endform_i intValueAt: 1];
	strncpy (side->ends.floorflat, [endform_i stringValueAt: 2], 9);
	strncpy (side->ends.ceilingflat, [endform_i stringValueAt: 3], 9);
	side->ends.lightlevel = [endform_i intValueAt: 4];
	side->ends.special = [endform_i intValueAt: 5];

	return self;
}

/*
==================
=
= setSide:
=
= Sets fields in a form object based on a mapside structure
==================
*/

- setSide: (worldside_t *)side
{
	[sideform_i setIntValue: side->flags at: 0] ;
	[sideform_i setIntValue: side->firstcollumn at: 1];
	[sideform_i setStringValue: side->toptexture at: 2];
	[sideform_i setStringValue: side->midtexture at: 3];
	[sideform_i setStringValue: side->bottomtexture at: 4];
	[sideform_i setIntValue: side->midheight at: 5];
	
	[endform_i setIntValue: side->ends.floorheight at: 0];
	[endform_i setIntValue: side->ends.ceilingheight at: 1];
	[endform_i setStringValue: side->ends.floorflat at: 2];
	[endform_i setStringValue: side->ends.ceilingflat at: 3];
	[endform_i setIntValue: side->ends.lightlevel at: 4];
	[endform_i setIntValue: side->ends.special at: 5];
	
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
	int		side;
	worldline_t	*line;

	if (!window_i)
		return self;
		
	if (!force && ![window_i isVisible])
		return self;

	[window_i disableFlushWindow];
	
	line = &baseline;
	
	//
	// write values out
	//
	[p1_i setIntValue: line->p1];
	[p2_i setIntValue: line->p2];
	
	[special_i setIntValue: line->special];
	
	[pblock_i setState:  (line->flags&ML_BLOCKMOVE) > 0];
	[twosided_i setState:  (line->flags&ML_TWOSIDED) > 0];

	side = [sideradio_i selectedCol];	
	[self setSide: &line->side[side]];

	[window_i reenableFlushWindow];
	[window_i flushWindow];
	
	return self;
}

//============================================================================


- changeLineFlag: (int)mask to: (int)set
{
	int	i;
	worldline_t	*line;
	
	for (i=0 ; i<numlines ; i++)
		if (lines[i].selected > 0)
		{
			line = &lines[i];
			line->flags &= mask;
			line->flags |= set;
			[editworld_i changeLine: i to: line];
		}
		
	[editworld_i updateWindows];
	return self;
}

- blockChanged: sender
{
	int	state;
	state = [pblock_i state];	
	[self changeLineFlag: ~ML_BLOCKMOVE  to: ML_BLOCKMOVE*state];
	return self;
}


- twosideChanged: sender;
{
	int	state;
	state = [twosided_i state];	
	[self changeLineFlag: ~ML_TWOSIDED  to: ML_TWOSIDED*state];
	return self;
}

- specialChanged: sender
{
	int		i,value;
	
	value = [special_i intValue];	
	for (i=0 ; i<numlines ; i++)
		if (lines[i].selected > 0)
		{
			lines[i].special = value;
			[editworld_i changeLine: i to: &lines[i]];
		}
	
	[editworld_i updateWindows];
	return self;
}


- sideChanged: sender
{
	int		i,side;
	worldside_t	new;
	worldline_t	*line;
	
	side = [sideradio_i selectedCol];
	[self getSide: &new];
	for (i=0 ; i<numlines ; i++)
		if (lines[i].selected > 0)
		{
			line = &lines[i];
			line->side[side] = new;
			[editworld_i changeLine: i to: line];
		}
	
	[editworld_i updateWindows];
	return self;
}



//============================================================================


/*
==============
=
= updateLineInspector
=
==============
*/

- updateLineInspector
{
	int		i;
	worldline_t	*line;
		
	line = &lines[0];
	for (i=0 ; i<numlines ; i++, line++)
		if (line->selected > 0)
		{
			baseline = *line;
			break;
		}
		
	if (bcmp (&baseline, &oldline, sizeof(baseline)) )
	{
		memcpy (&oldline, &baseline, sizeof(oldline));
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


/*
===================
=
= baseLine:
=
= Returns the values currently displayed, so that a new line can be drawn with
= those values
=
===================
*/

- baseLine: (worldline_t *)line
{
	*line = baseline;
	return self;
}


@end
