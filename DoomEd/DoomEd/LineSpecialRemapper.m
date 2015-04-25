#import	"LinePanel.h"
#import "LineSpecialRemapper.h"
#import	"SpecialList.h"

id	lineSpecialRemapper_i;

@implementation LineSpecialRemapper

//===================================================================
//
//	REMAP Line Specials IN MAP
//
//===================================================================
- init
{
	lineSpecialRemapper_i = self;
	
	remapper_i = [ [ Remapper	alloc ]
				setFrameName:"LineSpecialRemapper"
				setPanelTitle:"Line Special Remapper"
				setBrowserTitle:"List of line specials to be remapped"
				setRemapString:"Special"
				setDelegate:self ];
	return self;
}

//===================================================================
//
//	Bring up panel
//
//===================================================================
- menuTarget:sender
{
	[remapper_i	showPanel];
	return self;
}

- addToList:(char *)orgname to:(char *)newname;
{
	[remapper_i	addToList:orgname to:newname];
	return self;
}

//===================================================================
//
//	Delegate methods
//
//===================================================================
- (char *)getOriginalName
{
	char	string[80];
	speciallist_t	special;

	[lineSpecialPanel_i fillSpecialData:&special];
	sprintf(string,"%d:%s",special.value,special.desc);
	return string;
}

- (char *)getNewName
{
	return [self getOriginalName];
}

- (int)doRemap:(char *)oldname to:(char *)newname
{
	int		i;
	int		linenum;
	int		flag;
	char	string[80];
	int		oldval;
	int		newval;
	
	sscanf(oldname,"%d:%s",&oldval,string);
	sscanf(newname,"%d:%s",&newval,string);
	
	linenum = 0;
	for (i = 0;i < numlines; i++)
	{
		flag = 0;
		
		if (lines[i].special == oldval)
		{
			lines[i].special = newval;
			flag++;
		}
		
		if (flag)
		{
			printf("Remapped Line Special %s to %s.\n",oldname,newname);
			linenum++;
		}
	}
	
	return linenum;
}

- finishUp
{
	return self;
}


@end
