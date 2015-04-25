
#import <appkit/appkit.h>

extern id	texturePalette_i;

typedef struct
{
	id	image;
	char	 name[9];
	NXRect	r;
} texpal_t;

@interface TexturePalette:Object
{
	id	window_i;
	id	texturePalView_i;
	id	texturePalScrView_i;
	id	titleField_i;
	id	widthField_i;
	id	heightField_i;
	
	id	texturePatches;
	id	allTextures;
	int	selectedTexture;
}

- initTextures;
- deleteTexture:sender;
- (int) getNumTextures;
- createAllTextureImages;
- (texpal_t) createTextureImage:(int)which;
- computePalViewSize;
- (texpal_t *)getTexture:(int)which;
- storeTexture:(int)which;
- (int) currentSelection;
- selectTexture:(int)val;
- menuTarget:sender;

@end
