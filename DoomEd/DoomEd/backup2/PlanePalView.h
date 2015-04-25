
#import <appkit/appkit.h>

@interface PlanePaletteView:View
{
	int	selectedPlane;
	id	planePalView_i;
}

- (int)currentViewSelection;

@end
