
#import "ThermoView.h"

@implementation ThermoView

- setThermoWidth:(int)current max:(int)maximum
{
	thermoWidth = bounds.size.width*((float)current/(float)maximum);
	return self;
}

- drawSelf:(const NXRect *)rects :(int)rectCount
{
	PSsetlinewidth(bounds.size.height);

	PSsetrgbcolor(0.5,1.0,1.0);
	PSmoveto(0,bounds.size.height/2);
	PSlineto(thermoWidth,bounds.size.height/2);
	PSstroke();
	
	PSsetgray(0.5);
	PSmoveto(thermoWidth+1,bounds.size.height/2);
	PSlineto(bounds.size.width,bounds.size.height/2);
	PSstroke();

	return self;
}

@end
