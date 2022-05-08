package parasol.filters;

import parasol.shaders.CombiningShader;
import openfl.display.BitmapData;
import openfl.display.Shader;
import openfl.display.DisplayObjectRenderer;
import parasol.shaders.BlurShader;
import parasol.shaders.ThresholdShader;
import openfl.filters.BitmapFilter;

/**
 * Bloom filter implements a bloom filter effect using several underlying shaders, a ThresholdShader to find
 * bright spots, a BlurShader to blur the bright spots, and a CombiningShader to combine the output of the
 * BlurShader with the original image to produce the bloom effect.
 * 
 * See https://learnopengl.com/Advanced-Lighting/Bloom for the details of the approach that this filter follows.
 *    Plus Jonathan Hopkins comment on this on how to produce kernels, which is mostly how the kernel computation is done here.
 */
class BloomFilter extends BitmapFilter {
    private var _thresholdShader:ThresholdShader;
    private var _blurShader:BlurShader;
    private var _combiningShader:CombiningShader;

    private var _width:Float;
    private var _height:Float;

    private var _blurShaderPasses:Int;
    private var _currentPass:Int;

    var _brightnessThreshold:Float;
    var _blurPasses:Int;

    /**
     * Create a new BloomFilter instance.
     * Width and height are used to work out the texel size.
     * Bright spots will be extracted and then blurred and recombined with the original image to create the
     * bloom effect.
     * @param width width of the area over which the bloom is to be applied
     * @param height height of the area over which the bloom is to be applied
     * @param initBrightnessThreshold the Luma threshold for bright spots 
     * @param initBlurPasses number of passes to create the blur. Will be clamped to an even value >= 0.
     */
    public function new(width:Float, height:Float, initBrightnessThreshold:Float, initBlurPasses:Int) {
        super();

        _width = width;
        _height = height;
        _brightnessThreshold = initBrightnessThreshold;

        _blurPasses = makeBlurPassesEven(initBlurPasses);

        /* Set the number of passes to be 1 for thresholding, _blurPasses for blurring, and one for
         * finally combining the blur and the original image.
         */
        __numShaderPasses = _blurPasses + 2;
        _currentPass = 0;

        // Create the necessary shaders
        _blurShader = new BlurShader(width, height);
        _thresholdShader = new ThresholdShader(0.8);
        _combiningShader = new CombiningShader();

        __preserveObject = true; // Retain the original bitmap so that we can additively blend the blur
                                 // with it.
    }

    @:noCompletion private override function __initShader(renderer:DisplayObjectRenderer, pass:Int, sourceBitmapData: BitmapData):Shader {
        _currentPass = pass;
        switch(_currentPass) {
            case 0:
                return _thresholdShader;
            case p if (p > 0 && p < __numShaderPasses - 1):
                _blurShader.u_horizontal.value[0] = !_blurShader.u_horizontal.value[0];
                return _blurShader;
            case p if (p == __numShaderPasses - 1):
                _combiningShader.sourceBitmap.input = sourceBitmapData;
                return _combiningShader;
            default:
                return null; // if out of range do nothing. FIXME This is technically and error and we should puke.
        }
    }

    /**
     * Update the filter parameters. Mostly used for demos rather than for production filter use.
     * @param brightnessThreshold the Luma threshold for bright spots.
     * @param numBlurPasses number of passes to create the blur. Will be clamped to an even value >= 0.
     */
    public function update(brightnessThreshold:Float, numBlurPasses:Int):Void {

        // Update the brightness threshold if it has changed
        if (_brightnessThreshold != brightnessThreshold) {
            _thresholdShader.update(brightnessThreshold);
            _brightnessThreshold = brightnessThreshold;
        }

        // Update the number of blur passes if it has changed
        var p = makeBlurPassesEven(numBlurPasses);
        if (_blurPasses != p) {
            _blurPasses = p;
            __numShaderPasses = _blurPasses + 1;
        }   
    }

    /**
     * Make sure we only ever set the blur shader passes to an even number so we have an
     * equal number of horizontal and vertical passes.
     * @param passes the number to check
     * @return Int the number of passes set to an even number >= 0.
     */
    private function makeBlurPassesEven(passes:Int):Int {
        if (passes < 0) {
            return 0;
        }
        if (passes % 2 != 0) {
            return passes + 1;
        }
        return passes;
    }
}
