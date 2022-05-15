# Filters

- [Filters](#filters)
  - [What Are Filters](#what-are-filters)
    - [Multiple Cameras](#multiple-cameras)
  - [How to Create a Filter](#how-to-create-a-filter)
    - [Key Classes](#key-classes)
    - [BloomFilter as an example of subclassing BitmapFilter](#bloomfilter-as-an-example-of-subclassing-bitmapfilter)
  - [Testing](#testing)
  - [References](#references)

## What Are Filters

Filters are shaders applied for post-processing effects. This means that the entire scene is rendered. As such most of the effect is created with fragment shaders. Filters maybe applied to the `FlxGame` or to individual `FlxCamera`s. Each may have multiple filters applied. In addition filters themselves may be comprised of multiple shaders. Thus you can achieve very complex effects.

### Multiple Cameras

The advantage of applying filters are the camera level is that you can restrict the objects a filter affects by rendering them only to a specific camera. The `parasol` examples for the `BloomFilter` do this so that the test image is affected by the UI elements controlling the filter properties are not.

## How to Create a Filter

We will now discuss how to create a multi-shader filter with reference to the bloom filter available in Parasol.

### Key Classes

Both `FlxGame` and `FlxCamera` have `setFilters()` methods which take an `Array<BitmapFilter>`. They also have a `filtersEnabled` boolean which can turn on or off all the filters. Filters themselves are subclasses of `openfl.filters.BitmapFilter` and they operate on `openfl.display.BitmapData` objects. These are available in `FlxSprite.pixels` field. In a shader this field is available as a `sampler2D` type called `bitmap`.

There are two base classes that you may subclass to create a filter of your own. The first is `openfl.filters.ShaderFilter` which provides a simple way to create a single shader filter. This is not discussed futher here at the present. The second is `openfl.filters.BitmapFilter`. `ShaderFilter` is in fact a subclass of `BitmapFilter` so the latter is the more general. The major advantage of using `BitmapFilter` is its ability to run multiple shader passes and combine the effects of multiple shaders into the final image. All further discussion here will center on this base class.

### BloomFilter as an example of subclassing BitmapFilter

The `parasol.filters.BloomFilter` implements a Bloom filter according to the recipe in Learn OpenGL by Joey De Vries. See the references below for a link to read up in detail how this filter works.

The `BitmapFilter` class provides support having shaders work together one processing the output of another and so on. It can also preserve the original bitmap data so that you can blend the effects of the shaders with the original image before finally outputting it for display. `parasol` uses these capabilities in the `parasol.filters.BloomFilter` class, which will be described in more detail below.

In order to preserve the original bitmap so that you can use it later your filter must set `__preserveObject = true;` and at some point in your override `__initShader` method it must pass the `sourceBitmapData` parameter to the final shader via its `sourceBitmap.input` sampler input variable.

`BloomFilter` does this at the end of its constructor.

```
        __preserveObject = true; // Retain the original bitmap so that we can additively blend the blur
                                 // with it.
    }
```

It is worth looking at the `BloomFilter.hx` file as we go through the discussion but the `__initShader` method code is reproduced here for convenience.

```
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
                return null; // if out of range do nothing.
        }
    }
```

`BitmapFilter` the `__initShader` method `__numShaderPasses` times. Each time it is called the function can configure and return an `openfl.display.Shader`. So a filter is able to return as many shaders as it wishes and determine the order in which they are returned and how they are configured. In order to make this possible the `__initShader` method is passed a `pass` argument which is a 0-based number incrementing on each pass. `BloomFilter` overrides the `__initShader` method to return one of three shaders depending upon the value of `pass`.

When `pass` is zero it returns a `parasol.shaders.ThresholdShader` whose job is to extract the bright spots of the input image.

Following that it returns `parasol.shaders.BlurShader`, for `pass` > 0 and < `__numShaderPasses - 1`. This shader provides a Gaussian blur to the hot spots extracted by the ThresholdShader. This is possible because the `bitmap` `sampler2D` uniform points to the output of the previous shader pass as the input for this shader pass. This is done an even number of times so that half that number may be used to blur in the horizontal direction and half in the vertical direction with an equal number in each direction. Finally, on the last pass it returns a `parasol.shaders.CombiningShader`. This shader combines the output of the blur passes with the original image to produce a final image containing blurred hotspots on top of the original unblurred image. This results in the classic bloom effect. 

Before the final CombiningShader is returned the `sourceBitmap` is retrieved from the `__initShader` `sourceBitmap` argument and put into the CombiningShader. This provides it with two `sampler2D` uniforms which it combines, `sourceBitmap` and the usual `bitmap` which is the output of the blur passes. Combining is simply additive.

## Testing

Testing the filter is best done visually and the `parasol.examples` project has a Bloom filter example. This is set up in the `examples.examples.states.BloomFilterState` class which configures a `FlxState` with multiple test images and a way to control the filter properties so that the effects can be seen. This may be altered to add images more appropriate to your particular test case so that you can determine the values to use for you own application.

Be aware that setting high numbers of blur passes will introduce noticeable lag in rendering.

## References

   * https://learnopengl.com/Advanced-Lighting/Bloom. This is the recipe upon which `parasol.filters.BloomFilter` is based.
