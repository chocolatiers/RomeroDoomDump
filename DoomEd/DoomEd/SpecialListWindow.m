#import "SpecialList.h"
#import "DoomProject.h"
#import "SpecialListWindow.h"
#import	"TextureEdit.h"

@implementation SpecialListWindow

- setParent:(id)p
{
	parent_i = p;
	return self;
}

//===================================================================
//
//	Match keypress to first letter
//
//===================================================================
- keyDown:(NXEvent *)event
{
	char	key[2];
	char	string2[32];
	int		max;
	int		i;
	speciallist_t	*s;
	id		specialList_i;
	int		found;
	int		size;
	int		tries;
	
	key[0] = event->data.key.charCode;
	strcat(string,key);
	strupr(string);
	size = strlen(string);
		
	specialList_i = [parent_i  getSpecialList];
	max = [specialList_i	count];
	tries = 2;
	while(tries)
	{
		found = 0;
		
		for (i = 0;i < max; i++)
		{
			s = [specialList_i	elementAt:i];
			strcpy(string2,s->desc);
			strupr(string2);
				
			if (!strncmp(string,string2,size))
			{
				[parent_i	scrollToItem:i];
				found = 1;
				tries = 0;
				break;
			}
		}
		
		if (!found)
		{
			string[0] = key[0];
			string[1] = 0;
			strupr(string);
			size = 1;
			tries--;
		}
	}
	return self;
}

@end
