# Converting a ShaderToy shader to HaxeFlixel

This document walks through the conversion of a shader from Shadertoy form to one useable in Flixel.
Often people will want a filter rather than a shader. Creating a filter is the last step. First create a 
FlxShader subclass that works. From that you can then easily create a filter if required.

Shaders on shadertoy may use features that are not supported in the version of GLSL that flixel/openfl/lime provides. They will almost certainly call variables by unfamiliar names. Some things will just not be required, such as the fragment coordinates will be scaled down explicitly in the GLSL code. This is done for you in openfl shader code.

Our example to convert is https://www.shadertoy.com/view/WdGcRh. This produces effects rather similar to old black and white movie projection or perhaps TV as it is billed.

## Things to Convert

While not an exhaustive list here are things that must be converted

  * Create a new `FlxShader` subclass for the shader.
  * All the fragment shader code from shadertoy must be pasted into a `@:glFragmentSource` metadata above the constructor `new()` function in your FlxShader subclass.
  * At the top of the `@:glFragmentSource` insert a `#pragma header` statement. Openfl will then insert an appropriate header of additional information.
  * If you are deploying to HTML5 WebGL will require that the float precision value be set. If this is the case add a `precision mediump float;` directive at the top of the shader code.
  * References to the texture() or texture2D() functions should be converted to flixel_texture2D()
  * iChannel0 references are the base image or video subjected to shading. This will be the sprite `bitmap`. You should change `iChannel0` to `bitmap` but there is no need to create a sampler2D uniform for it. Openfl will do this for you.
  * iChannelX where X > 0 are additional texture inputs. These you need to add `uniform sampler2D iChannelX` variables at the top of the shader.
  * there must be a `main()` functin with that name in flixel shaders. Shadertoy generally uses `mainImage()` so you will need to change that.
  * In general more modern `in` and `out` variable designations are not supported and you must use `varying` for output variables. The input variable to the fragment shader will have the same name as the `varying` from the vertex shader and can be just used. It does not need to be declared in the GLSL fragment shader code. Shadertoy's `mainImage()` may have `in` and `out` variables defined and they will have to be removed.
  * Fragment shaders use a coordinate between 0.0 and 1.0. So you will often see this construction `fragCoord / iResolution.xy` or similar. This can be replaced with `openfl_TextureCoordv` which is already scaled.
  * The final output color is defined as an `out` variable in many shaders using more modern syntax. The final line of the `main()` function in flixel shaders must assign the color value to the standard variable `gl_FragColor` which is a `vec4`, thus including an alpha value.


## Step by step example

   * Create a flixel project to do the conversion in. It can be called anything you like. You could even just create a general shader conversion project to reuse many times.
     * `flixel tpl -n shadertoyconversion`
   * Create a FlxShader subclass called whatever makes sense. In this case I used OldTVShader.hx
   * In your PlayState create a FlxSprite with and load a test image into it. Set the shader on it and add it to the state.
  ```
  	override public function create()
	{
		super.create();

		_testSprite = new FlxSprite();
		_testSprite.loadGraphic(AssetPaths.pexels_pixabay_73873__png);

		_oldTVShader = new OldTVShader();
		_testSprite.shader = _oldTVShader;
		add(_testSprite);
	}
```

   * Now cut and paste the shader code into shader class into a `@:glFragmentSource` metadata above the constructor.
   * Do a test compilation so that you know that it builds. It won't run successfully yet but it's good to know that the Haxe code is building. Of course it may give you errors and you should fix any of those that you can. This is all about being able to test the conversion as you go.
   * I suspect none of the images on this shader are subject to a license retriction but as I can find no direct statement to that effect I have left them out of the repo.
      * Download the iChannelX images from shadertoy (subject to licensing) or get your own. The channels > 0 will likely be sampler textures and will affect the outcome if you use something much different. In this case I downloaded the pebbles and the abstract3 textures and put them in the `assets/images` location. You can do that or use your own textures. If you name the textures differently you will need to update the file names below.
   * You will also need a test image for your sprite. I used a photograph of a nebula from pixabay.
   * Any errors related to the shader (GLSL) code itself will have to be resolved as we proceed below.

The first thing you need to do is to add a `#pragma header` directive at the very start of the GLSL code like this:

```
	@:glFragmentSource('
        #pragma header
        
        //////////////////////////////////////////////////////////////////////////////////////////
        //
        //	 OLD TV SHADER
        //
        //	 by Tech_
```

Next you need to look at the inputs required by the shader. The Shadertoy Shader Inputs section shows all the inputs available, but they are not all necessarily used by the shader you are converting. Look at things that are actually used.

Go through the shader code line by line. You will arrive at code eventually that has a variable that is not available in the current context - not in the function parameters, not locally defined, not in a global. This is very likely a shader input, attribute, uniform or sampler, that you will need to provide through your shader subclass.

Walking through our example then we come to :

   * #define's - these are all GLSL constants so are ok
   * luma function - this only refers to GLSL types and functions (vec3 and dot) and the color function parameter. Nothing to convert here.
   * saturate function - again either GLSL types and functions, or function parameters, or locals (intensity) or other function calls (luma). Again nothing to convert here.
   * Next comes flicker. Here we have one value that is not a local variable, a GLSL function, a literal, or a function argument. That is iTime. If you look at the shadertoy Shader Inputs section you will see that this is defined as the "shader playback time (in seconds)" and it's defined as a float.

iTime this is equivalent to the game running time or the time since the playstate started, or the time since the shader started running. The point is it is an increasing count of time. The usual way this is handled is by summing up the elapsed time in the update method and passing that to a shader uniform.

   * Create a uniform float with the name you want. If you use iTime it won't need to be changed everywhere in the GLSL code. If you want a different name you will need to update all occurrences of iTime to that name.

```
        //////////////////////////////////////////////////////////////////////////////////////////

        uniform float iTime;
        
        float luma(vec3 color)
```

Now in the constructor (new()) function you will need to initialize
this value, and then because this is the time value you will need to provide a way for it to be updated and make sure that the PlayState update() function calls the shader to update this value.

In OldTVShader.hx your constructor should now look like:

```
	public function new()
	{
		super();

		this.iTime.value = [0.0];
	}
```

You also need an update() function so add this after the constructor:

```
public function update(iTime:Float):Void {
    this.iTime.value = [iTime];
}
```

In PlayState.update() you should add a call to the shader update function:

```
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		_cummTime += elapsed;
		_oldTVShader.update(_cummTime);
	}
```

Don't forget to initialize _cummTime to 0.0 in the create function:

```
	override public function create()
	{
		super.create();

		_cummTime = 0.0;
```

We can now go back to the shader code to the next function, `filmStripes`. This function only contains literals, GLSL functions, local variables and function arguments. Nothing to convert here.

The next three, `filmGrain`, `vignette`, `reinhard` 
 are the same - nothing to convert.

In `filmDirt` though we encounter the following items that need conversion:

   * `iTime` which is already done.
   * `iResolution`
   * the `texture` GLSL function
   * the `iChannel1` texture sampler

`iResolution` is usually used to scale down coordinates to be in the range 0.0 through 1.0. This is not necessary to do with flixel/opfenl shaders because the openfl vertext shader emits a varying called `openfl_TextureCoordv` which is already scaled.

But `iResolution` is also used to get the aspect ratio which is the case here. So create another uniform and pass in the width and height of the enclosing flixel entity. This will either be the FlxSprite width and height or the FlxCamera width and height or the FlxGame width and height.

So at the top of the shader code we add a second uniform.

```
        uniform float iTime;
        uniform vec2 iResolution;
```

We make it a vec2 as we are only working in 2D. Then in the OldTVShader we add this in the constructor. There is no need for a change in update() unless you have to support resizing.

```
	public function new(width:Float, height:Float)
	{
		super();

		this.iTime.value = [0.0];
		this.iResolution.value = [width, height];
	}
```

Note that these are constructor parameters which must be supplied from the PlayState call so we update PlayState also.

```
		_oldTVShader = new OldTVShader(_testSprite.width, _testSprite.height);
```

Next up is the texture() function. This is a standard GLSL function to sample a texel from a texture. Flixel provides a wrapper for this function which handles any transform you may have on the sprite. So we should update this call to become:

```
            float noise = luma(flixel_texture2D(iChannel1, st).rgb);

```

Finally the iChannel1 should be providing the texture that we want to sample. So we need to add a new sampler2D variable at the top of the shader code and set it to a value in the OldTVShader.

Add a new sampler:

```
        uniform float iTime;
        uniform vec2 iResolution;
        uniform sampler2D iChannel1;
```

and pass in a value in OldTVShader:

Now we move to the next function `filmNoise` which has two more invocations of `texture()`  and another texture `iChannel2`. So again we change those `texture()` calls to `flixel_texture2D()` in the shader code.

```
            float tex1 = luma(flixel_texture2D(iChannel2, uv.yx).rgb);
            float tex2 = luma(flixe_texture2D(iChannel2, st).rgb);
```

And now we add a new sampler for iChannel2 and load the texture file for that and assign it in the constructor.

```
        uniform float iTime;
        uniform vec2 iResolution;
        uniform sampler2D iChannel1;
        uniform sampler2D iChannel2;
```
and in the constructor add this under the pebble texture

```
		// Read the noise texture
		var noise = new FlxSprite(0, 0);
		noise.loadGraphic(AssetPaths.abstract3__jpg);
		this.iChannel2.input = noise.pixels;
```

Now finally we reach `mainImage()` where we have another call to `texture()` which we fix in the usual manner. But here the texture is iChannel0. This is actually the test image. In the shadertoy original this was the movie image of the google logo. In our case it will be the FlxSprite bitmap.

So
```
            vec3 col = texture(iChannel0, uv).rgb;
```

becomes

```
            vec3 col = flixel_texture2D(bitmap, uv).rgb;
```

Next the main function must be changed from

```
        void mainImage( out vec4 fragColor, in vec2 fragCoord )
        {
```

to 
```
        void main()
        {
```

Now this begs the question as to what about the input fragment coordinate variable from the vertex shader and what should be the output color variable from the fragment shader to the display.

Note that fragCoord is used in this code

```
            // Normalized pixel coordinates (from 0 to 1)
            vec2 uv = fragCoord / iResolution.xy;
```
This is what I was referring to right at the beginning. The iResolution is being used to scale the fragment coordinate. This is not required and we can just replace these lines with:

```
            // Normalized pixel coordinates (from 0 to 1)
            vec2 = openfl_TextureCoordv;
```

And finally at the end of `mainImage()` now renamed `main()` we have 

```
            // Output to screen
            fragColor = vec4(col, 1.);
```

This must be changed to

```
            // Output to screen
            gl_FragColor = vec4(col, 1.);
```

At this point the test program should build and run.

## Using the Shader as a Filter

If you want to apply the shader to the entire game or to a camera you will need to wrap the shader
in a ShaderFilter and apply it to a camera. To do this you will need code like the following added
somewhere where you setup the camera.

```
		_oldTVShader = new OldTVShader(FlxG.width, FlxG.height);
		_oldTVFilter = new ShaderFilter(_oldTVShader);
		FlxG.camera.setFilters([_oldTVFilter]);
		FlxG.camera.filtersEnabled = true;
```
