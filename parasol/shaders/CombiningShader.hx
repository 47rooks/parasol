package parasol.shaders;

import flixel.system.FlxAssets.FlxShader;

/**
 * A CombiningShader combines two textures into one output. They are the
 * sourceBitmap and the openfl_Texture bitmaps. This shader is expected to be used
 * in a openfl.filters.BitmapFilter subclass, which is expected to set the `sourceBitmap.input`
 * field before returning this shader to the filter driver code. See `parasol.filters.BloomFilter`
 * for example usage.
 */
class CombiningShader extends FlxShader {

    @:glFragmentSource('
        #pragma header

        uniform sampler2D sourceBitmap;
        uniform sampler2D openfl_Texture;

        void main()
        {
            vec2 st = openfl_TextureCoordv.xy;  // Note, already normalized

            vec4 blurColor = flixel_texture2D(bitmap, st);
            vec4 originalColor = flixel_texture2D(sourceBitmap, st);
            gl_FragColor = blurColor + originalColor;
        }
    ')
    /**
     * Return a new CombiningShader.
     */
    public function new() {
        super();
    }
}