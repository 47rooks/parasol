package parasol.shaders;

import flixel.system.FlxAssets.FlxShader;

/**
 * Pixelate to the specified pixel width and height.
 */
class PixelationShader extends FlxShader
{
	var _spriteWidth:Float;
	var _spriteHeight:Float;
    
    /**
     * The height of the pixelation pixel.
     */
    public var pixelHeight(get, set):Float;
    
    /**
     * The width of the pixelation pixel.
     */
    public var pixelWidth(get, set):Float;
    
	@:glFragmentSource('
        #pragma header

        uniform float uWidth;
        uniform float uHeight;
        uniform float uPixelWidth;
        uniform float uPixelHeight;

        void main() {
            vec2 st = openfl_TextureCoordv.xy;  // Note, already normalized
            float x = floor(floor(openfl_TextureCoordv.x * uWidth / uPixelWidth) * uPixelWidth) / uWidth;
            float y = floor(floor(openfl_TextureCoordv.y * uHeight / uPixelHeight) * uPixelHeight) / uHeight;
            
            // Output the color
            gl_FragColor = flixel_texture2D(bitmap, vec2(x, y));    
        }
    ')
    /**
     * Constructor
     * @param width the width of the image in pixels
     * @param height the height of the image in pixels
     * @param pixelWidth the width of a pixelated 'pixel'
     * @param pixelHeight the height of a pixelated 'pixel'
     */
    public function new(width:Float, height:Float, pixelWidth:Float=1.0, pixelHeight:Float=1.0)
	{
		super();
		_spriteWidth = width;
        _spriteHeight = height;

        uWidth.value = [_spriteWidth];
        uHeight.value = [_spriteHeight];
        uPixelWidth.value = [pixelWidth];
        uPixelHeight.value = [pixelHeight];
	}

	function get_pixelHeight():Float {
		return uPixelHeight.value[0];
	}

	function set_pixelHeight(value:Float):Float {
		uPixelHeight.value = [value];
        return value;
	}

	function get_pixelWidth():Float {
		return uPixelWidth.value[0];
	}

	function set_pixelWidth(value:Float):Float {
		uPixelWidth.value = [value];
        return value;
	}
}
