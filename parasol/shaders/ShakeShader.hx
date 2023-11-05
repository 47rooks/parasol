package parasol.shaders;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;

/**
 * The ShakeShader shakes the image by manipulating the vertexes.
 * Blur may be added and the shake intensity and duration are 
 * configurable.
 */
class ShakeShader extends FlxShader {
	/* Shake parameters */
	var _shakeIntensity:Float;
	var _shakeDuration:Float;
    var _blur:Bool;
    
    @:glVertexHeader("
        uniform bool shakeOn;
        uniform vec2 shakeOffset;
    ")
    @:glVertexBody("
        if (shakeOn) {
            gl_Position.xy += shakeOffset;
        }
    ")
    @:glFragmentSource("
        #pragma header

        uniform mat3 blur_kernel;
        uniform bool shakeOn;
        uniform bool blurOn;
        uniform mat3 offsets_x;
        uniform mat3 offsets_y;

        void main() {
            vec4 color = vec4(0.0);
            vec3 sample[9];

            if (shakeOn && blurOn) {
                float x = openfl_TextureCoordv.x;
                float y = openfl_TextureCoordv.y;
    
                // Sample texture offsets using the convolution matrix
                for (int i=0; i<3; i++) {
                    for (int j=0; j<3; j++) {
                        sample[i*3 + j] = flixel_texture2D(bitmap, vec2(x + offsets_x[i][j], y + offsets_y[i][j])).rgb;
                    }
                }
                
                for (int i=0; i<3; i++) {
                    for (int j=0; j<3; j++) {
                        color += vec4(sample[i*3 + j] * blur_kernel[i][j], 0.0);
                    }
                }
                color.a = 1.0;
            } else {
                color = flixel_texture2D(bitmap, openfl_TextureCoordv);
            }
            gl_FragColor = color;
        }
    ")
    /**
     * Return a new ShakeShader.
     */
    override public function new() {
        super();
        shakeOn.value = [false];
        blurOn.value = [false];
		shakeOffset.value = [0.0, 0.0];

		final offset = 1.0 / 1280.0;
		offsets_x.value = [-offset, 0.0, offset, -offset, 0.0, offset, -offset, 0.0, offset];
		offsets_y.value = [offset, offset, offset, 0.0, 0.0, 0.0, -offset, -offset, -offset];
        
        blur_kernel.value = [
			1.0 / 16.0, 2.0 / 16.0, 1.0 / 16.0,
			2.0 / 16.0, 4.0 / 16.0, 2.0 / 16.0,
			1.0 / 16.0, 2.0 / 16.0, 1.0 / 16.0
		];
    }

    public function update(elapsed:Float):Void
    {
        _shakeDuration -= elapsed;
        if (_shakeDuration > 0.0)
        {
            var ox = FlxG.random.float(-_shakeIntensity, _shakeIntensity);
            var oy = FlxG.random.float(-_shakeIntensity, _shakeIntensity);
            shakeOffset.value = [ox, oy];
            shakeOn.value = [true];
            blurOn.value = [_blur];
        }
        else if (shakeOn.value[0])
        {
            shakeOn.value = [false];
            blurOn.value = [false];
        }
    }

   	/**
	 * Start shake effect
	 * @param intensity maximum proportion (0.0 to 1.0) of screen size to shake in either direction
	 * @param duration the time in seconds the shake will last
     * @param blur if true blur while shaking, else do not blur
	 */
	public function shake(intensity:Float = 0.05, duration = 0.5, blur:Bool = false):Void
    {
        if (intensity > 1.0)
        {
            _shakeIntensity = 1.0;
        }
        else if (intensity < 0.0)
        {
            _shakeIntensity = 0.0;
        }
        else
        {
            _shakeIntensity = intensity;
        }
        _shakeDuration = duration;
        _blur = blur;
    }
}