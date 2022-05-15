package parasol.shaders;

import flixel.system.FlxAssets.FlxShader;

/**
 * The ThresholdShader converts the pixel color value to a grayscale value and thresholds
 * it at a particular value. The threshold value may be updated by calling the update()
 * function.
 * 
 * For the grayscale conversion constants see https://en.wikipedia.org/wiki/Grayscale#Luma_coding_in_video_systems.
 */
class ThresholdShader extends FlxShader {

    @:glFragmentSource('
    #pragma header

    uniform float u_brightnessThreshold;

    void main()
    {
        vec2 st = openfl_TextureCoordv.xy;  // Note, already normalized

        vec4 color = flixel_texture2D(bitmap, st);
        if (dot(color.rgb, vec3(0.2126, 0.7152, 0.0722)) > u_brightnessThreshold) {
            gl_FragColor = color;
        } else {
            gl_FragColor = vec4(0.0);
        }
    }
    ')
    /**
     * Return a new ThresholdShader.
     * @param brightnessThreshold the initial threshold value, will be clamped to between 0 and 1 if outside this range.
     */
    override public function new(brightnessThreshold: Float) {
        super();
        this.u_brightnessThreshold.value = [clamp(brightnessThreshold)];
    }

    /**
     * Update the brightness threshold.
     * @param brightnessThreshold new threshold value,  will be clamped to between 0 and 1 if outside this range.
     */
    public function update(brightnessThreshold:Float) {
        this.u_brightnessThreshold.value = [brightnessThreshold];
    }

    /**
     * Clamp value to between 0.0 and 1.0.
     * @param val value to be clamped
     */
    private static function clamp(val:Float):Float {
        return Math.max(0.0, Math.min(1.0, val));
    }
}