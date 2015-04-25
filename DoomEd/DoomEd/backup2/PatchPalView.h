
#import <appkit/appkit.h>

@interface PatchPaletteView:View
{
	int	selectedPatch;
	id	patchPalView_i;
}

- (int)currentSelection;

@end
