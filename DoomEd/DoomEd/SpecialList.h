
#import <appkit/appkit.h>

typedef struct
{
	int		value;
	char		desc[32];
} speciallist_t;

@interface SpecialList:Object
{
	id	specialDesc_i;
	id	specialBrowser_i;
	id	specialValue_i;
	id	specialPanel_i;
	id	specialList_i;
	
	id	delegate;
	char		title[32];
	char		frameString[32];
}

- getSpecialList;
- scrollToItem:(int)i;
- setSpecialTitle:(char *)string;
- setFrameName:(char *)string;
- saveFrame;
- displayPanel;
- addSpecial:sender;
- suggestValue:sender;
- chooseSpecial:sender;
- updateSpecialsDSP:(FILE *)stream;
- (int)findSpecial:(int)value;
- validateSpecialString:sender;
- setSpecial:(int)which;
- fillSpecialData:(speciallist_t *)special;

@end
