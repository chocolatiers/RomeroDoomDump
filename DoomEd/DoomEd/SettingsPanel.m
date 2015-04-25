
#import "SettingsPanel.h"
#import "PreferencePanel.h"

id	settingspanel_i;

@implementation SettingsPanel

- init
{
	settingspanel_i = self;
	segmenttype = ONESIDED_C;
	return self;
}


- menuTarget:sender
{
    return self;
}

- (int) segmentType
{
	return segmenttype;
}

@end
