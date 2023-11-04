package parasol.shaders;

import parasol.shaders.ParasolShader;

class GrayscaleParasolShader extends ParasolShader {
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

    @:parasolLibraryFunction('shaderlib.fs', 'pixelate')
    @:parasolLibraryFunction('shaderlib.fs', 'grayscale')
    @:parasolFragmentShader('grayscale.fs')
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

        u_pixelSize.value = [pixelWidth, pixelHeight];
    }
    

    function get_pixelHeight():Float {
		return u_pixelSize.value[1];
	}

	function set_pixelHeight(value:Float):Float {
		u_pixelSize.value[1] = value;
        return value;
	}

	function get_pixelWidth():Float {
		return u_pixelSize.value[0];
	}

	function set_pixelWidth(value:Float):Float {
		u_pixelSize.value[0] = value;
        return value;
	}
}