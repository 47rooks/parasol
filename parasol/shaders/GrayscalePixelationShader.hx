package parasol.shaders;


import flixel.system.FlxAssets.FlxShader;
import parasol.macros.Macros;

/**
 * Pixelate to the specified pixel width and height.
 */
class GrayscalePixelationShader extends FlxShader
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
    // @:build(Macros.getShaderText('grayscale.fs'))
    static final fs:String = Macros.getShaderText('grayscale.fs');
    // final fragSource:String = 
    // @:glFragmentSource('#pragma header
    // ' +
    // // GrayscalePixelationShader.fs +
    // '
    //     uniform float uWidth;
    //     uniform float uHeight;
    //     uniform float uPixelWidth;
    //     uniform float uPixelHeight;

    //     void main() {
    //         vec2 st = openfl_TextureCoordv.xy;  // Note, already normalized

    //         float x = floor(floor(openfl_TextureCoordv.x * uWidth / uPixelWidth) * uPixelWidth) / uWidth;
    //         float y = floor(floor(openfl_TextureCoordv.y * uHeight / uPixelHeight) * uPixelHeight) / uHeight;
            
    //         // Output the color
    //         // gl_FragColor = flixel_texture2D(bitmap, vec2(x, y));    
    //         gl_FragColor = vec4(grayscale(bitmap, vec2(x, y)), 1.0);
    //     }
    // ')
    final fs_string = '#pragma header
   
        uniform float uWidth;
        uniform float uHeight;
        uniform float uPixelWidth;
        uniform float uPixelHeight;

        void main() {
            vec2 st = openfl_TextureCoordv.xy;  // Note, already normalized

            float x = floor(floor(openfl_TextureCoordv.x * uWidth / uPixelWidth) * uPixelWidth) / uWidth;
            float y = floor(floor(openfl_TextureCoordv.y * uHeight / uPixelHeight) * uPixelHeight) / uHeight;
            
            // Output the color
            // gl_FragColor = flixel_texture2D(bitmap, vec2(x, y));    
            gl_FragColor = vec4(grayscale(bitmap, vec2(x, y)), 1.0);
        }
    ';
//     @:glFragmentSource('#pragma header
   
//     uniform float uWidth;
//     uniform float uHeight;
//     uniform float uPixelWidth;
//     uniform float uPixelHeight;

//     void main() {
//         vec2 st = openfl_TextureCoordv.xy;  // Note, already normalized

//         float x = floor(floor(openfl_TextureCoordv.x * uWidth / uPixelWidth) * uPixelWidth) / uWidth;
//         float y = floor(floor(openfl_TextureCoordv.y * uHeight / uPixelHeight) * uPixelHeight) / uHeight;
        
//         // Output the color
//         // gl_FragColor = flixel_texture2D(bitmap, vec2(x, y));    
//         gl_FragColor = vec4(grayscale(bitmap, vec2(x, y)), 1.0);
//     }
// ')
    // @:glFragmentSource('${fs_string}')
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

        // uWidth.value = [_spriteWidth];
        // uHeight.value = [_spriteHeight];
        // uPixelWidth.value = [pixelWidth];
        // uPixelHeight.value = [pixelHeight];
        trace('setting fs=${GrayscalePixelationShader.fs}');
        // glVertexSource = 'foo';
        glFragmentSource = '#pragma header

        void main()
        {
            vec2 st = openfl_TextureCoordv.xy;  // Note, already normalized
    
            vec4 color = flixel_texture2D(bitmap, st);
            gl_FragColor = vec4(vec3(dot(color.rgb, vec3(0.2126, 0.7152, 0.0722))), color.a);
        }';
	}

	function get_pixelHeight():Float {
		// return uPixelHeight.value[0];
        return 0.0;
	}

	function set_pixelHeight(value:Float):Float {
		// uPixelHeight.value = [value];
        return value;
	}

	function get_pixelWidth():Float {
		// return uPixelWidth.value[0];
        return 0.0;
	}

	function set_pixelWidth(value:Float):Float {
		// uPixelWidth.value = [value];
        return value;
	}
}
