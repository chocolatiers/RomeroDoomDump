
#import <appkit/appkit.h>

typedef struct
{
	char		orgname[40],newname[40];
} type_t;

//
//	Methods to be implemented by the delegate
//
@protocol Remapper
- (char *)getOriginalName;
- (char *)getNewName;
- (int)doRemap:(char *)oldname to:(char *)newname;
- finishUp;
@end


@interface Remapper:Object
{
	id		original_i;
	id		new_i;
	id		remapPanel_i;
	id		remapString_i;
	id		status_i;
	id		browser_i;
	id		matrix_i;
	
	id		storage_i;
	id		delegate_i;
	char		frameName[32];
}

//	EXTERNAL USE
- setFrameName:(char *)fname
  setPanelTitle:(char *)ptitle
  setBrowserTitle:(char *)btitle
  setRemapString:(char *)rstring
  setDelegate:(id)delegate;

//extern - (int)doRemap:(char *)oldname to:(char *)newname;

- showPanel;
  
- addToList:(char *)orgname to:(char *)newname;

//	INTERNAL USE
- remapGetButtons:sender;
- doRemappingOneMap:sender;
- doRemappingAllMaps:sender;
- addToList:sender;
- deleteFromList:sender;
- clearList:sender;

@end
