
#import <appkit/appkit.h>
#import "EditWorld.h"

extern	id	linepanel_i;
extern	id	lineSpecialPanel_i;

@interface LinePanel:Object
{
	id	p1_i;
	id	p2_i;
	id	special_i;
	
	id	pblock_i;
	id	toppeg_i;
	id	bottompeg_i;
	id	twosided_i;
	id	secret_i;
	id	soundblock_i;
	id	dontdraw_i;
	id	monsterblock_i;
	
	id	sideradio_i;
	id	sideform_i;
	id	tagField_i;
	id	linelength_i;
	
	id	window_i;
	id	firstColCalc_i;
	id	fc_currentVal_i;
	id	fc_incDec_i;
	worldline_t	baseline, oldline;
}

- emptySpecialList;
- menuTarget:sender;
- updateInspector: (BOOL)force;
- sideRadioTarget:sender;
- updateLineInspector;

- monsterblockChanged:sender;
- blockChanged: sender;
- twosideChanged: sender;
- toppegChanged: sender;
- bottompegChanged: sender;
- secretChanged:sender;
- soundBlkChanged:sender;
- dontDrawChanged:sender;
- specialChanged: sender;
- tagChanged: sender;
- sideChanged: sender;

- getFromTP:sender;
- setTP:sender;
- zeroEntry:sender;
- suggestTagValue:sender;
- (int)getTagValue;

// FIRSTCOL CALCULATOR
- setFCVal:sender;
- popUpCalc:sender;
- incFirstCol:sender;
- decFirstCol:sender;

-baseLine: (worldline_t *)line;

- updateLineSpecial;
- activateSpecialList:sender;
- updateLineSpecialsDSP:(FILE *)stream;
@end
