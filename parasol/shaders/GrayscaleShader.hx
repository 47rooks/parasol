package parasol.shaders;

import flixel.system.FlxAssets.FlxShader;

/**
 * The GrayscaleShader converts the pixel color value to a grayscale value resulting in a
 * grayscale image.
 * 
 * For the grayscale conversion constants see https://en.wikipedia.org/wiki/Grayscale#Luma_coding_in_video_systems.
 */
class GrayscaleShader extends FlxShader {

    @:glFragmentSource('
    #pragma header

    void main()
    {
        vec2 st = openfl_TextureCoordv.xy;  // Note, already normalized

        vec4 color = flixel_texture2D(bitmap, st);
        gl_FragColor = vec4(vec3(dot(color.rgb, vec3(0.2126, 0.7152, 0.0722))), color.a);
    }
    ')
    /**
     * Return a new GrayscaleShader.
     */
    override public function new() {
        super();
    }
}