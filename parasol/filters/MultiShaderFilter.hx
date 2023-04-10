package parasol.filters;

import flixel.system.FlxAssets.FlxShader;
import haxe.ValueException;
import openfl.display.BitmapData;
import openfl.display.DisplayObjectRenderer;
import openfl.display.Shader;
import openfl.filters.BitmapFilter;

/**
 * A MultiShaderFilter combines the effects of multiple shaders in one filter.
 * Not all shaders will interact well this way or may need modification. Alternatively,
 * they may be better combined by integrating them into a single shader. This will certainly
 * be required if you wish to apply the combined shaders to a FlxSprite as filters cannot be
 * used there.
 */
class MultiShaderFilter extends BitmapFilter {
    private var _shaders:Array<FlxShader>;

    private var _currentPass:Int;

    /**
     * Create a new MultiShaderFilter.
     *
     * @param shaders shaders to apply. Shaders will be applied in the order in which they appear in the array.
     */
    public function new(shaders:Array<FlxShader>) {
        super();

        _currentPass = 0;

        // Not needed currently but there are cases where it is useful. See BloomFilter for an example.
        // __preserveObject = true; // Retain the original bitmap so that we can additively blend the blur
        //                          // with it.

        _shaders = shaders;
        
        // Set the number of shader passes.
         __numShaderPasses = _shaders.length;
    }

    @:noCompletion private override function __initShader(renderer:DisplayObjectRenderer, pass:Int, sourceBitmapData: BitmapData):Shader {
        if (pass >= _shaders.length) {
            throw new ValueException('pass ${pass} value greater that number of shaders ${_shaders.length}');
        }
        _currentPass = pass;

        return _shaders[pass];
    }
}
