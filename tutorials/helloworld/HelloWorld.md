# Hello World

- [Hello World](#hello-world)
  - [The Plan](#the-plan)
  - [Prerequisites](#prerequisites)
  - [The Development Environment](#the-development-environment)
    - [Clone the Parasol Github repo](#clone-the-parasol-github-repo)
    - [GLSL](#glsl)
  - [Some GLSL Basics](#some-glsl-basics)
  - [Simple Shapes](#simple-shapes)
    - [Rectangles](#rectangles)
    - [Circles](#circles)
    - [Semi-circles](#semi-circles)
    - [Lines](#lines)
  - [Making Letters](#making-letters)
  - [Bringing it into HaxeFlixel](#bringing-it-into-haxeflixel)
    - [Prepare a new HaxeFlixel Project](#prepare-a-new-haxeflixel-project)
    - [Running each version](#running-each-version)
    - [Stage1](#stage1)
      - [LetterShader.hx](#lettershaderhx)
      - [LetterSprite.hx](#letterspritehx)
      - [PlayState.hx](#playstatehx)
      - [Testing The First Cut](#testing-the-first-cut)
    - [Stage 2](#stage-2)
      - [PlayState.hx](#playstatehx-1)
    - [Stage 3](#stage-3)
      - [LetterShader.hx](#lettershaderhx-1)
      - [LetterSprite.hx](#letterspritehx-1)
    - [Conclusion](#conclusion)
  - [References](#references)

Every new programming language tutorial needs a "Hello World!".
This is such a tutorial for HaxeFlixel (HF) shaders.

## The Plan

As this will be done with a fragment shader we don't have any geometry to work with. Instead we will "paint" the letters by setting colors for pixels in the right place.

To keep the shapes simple we'll use a very blocky style, fixed width font with no ornamentation. This means rectangles and circles and semi-circles.

## Prerequisites

It is expected that you are familiar with Haxe, HaxeFlixel and VSCode. You could use another editor of course and a difference shader development environment that glsl-canvas but these are what I used. If you need help to setup any of these pieces there are instructions and tutorials on the web. They will not be covered here. Links can be found in the references.

## The Development Environment

### Clone the Parasol Github repo

You will need to clone the `parasol` github repository available at https://github.com/47rooks/parasol.

After cloning the repo go to the `parasol\tutorials\helloworld\helloworld` and follow the steps in the `README.md` file.

Open the `parasol\tutorials\helloworld\helloworld` project directory in a VSCode window. This should be able to build directory with the usual build keystrokes. In powershell you should be able to run the usual `lime build hl` or `lime test hl` commands. I have at this point only tested on Windows and Hashlink but other platforms and targets should be able to run this tutorial. No exotic target specific code is used and the shaders are very simple.

### GLSL

I'll use VSCode with the glsl-canvas plugin to develop the basic shader code. (You could use other tools if you are familiar with them but you may need to tweak the shader code.) So go ahead and install both VSCode and the glsl-canvas plugin now if you do not have them. It is assumed you also have a Haxe and HaxeFlixel installation that works. Some version of Haxe 4.x or above should be fine. I used 4.2.4. HaxeFlixel can be any reasonably current version, 4.10 in my case.

## Some GLSL Basics

A fragment shader operates on just a single fragment. For our purposes this is a pixel. The code we will write in the shader will determine the color for just one pixel. However, when it is run it will be run on a multitude of GPUs each being assigned a different fragment (pixel). Thus the entire screen of pixels is painted one pixel at a time in parallel.

You will notice that all numerical values assigned to floats have `.` following them even if there is no decimal value. This is required by GLSL and you will get errors if you try to assign and integer constant to a float variable.

## Simple Shapes

In order to create letter shapes we need to construct basic geometric shapes.

### Rectangles

There are various ways to draw a simple rectangle or square in GLSL. There are very commonly used functions that can help us here. One is `step()` and the other `smoothStep()`. `step()` will produce a very hard edge to the transition from one color to another, a step function. `smoothStep()` can produce a fading between colors, producing a soft edge.

You should read the [Khronos site documentation](https://www.khronos.org/registry/OpenGL-Refpages/gl4/) for these two functions but I'll give a simple description here also.

|Function|Description
|-|-|
|`step(edge, x)`|Generate a step function by comparing two values.  The x value is compared with the edge value and step() returns 0.0 if x is less than edge and 1.0 otherwise.|
|`smoothStep(edge0, edge1, x)`|Perform a Hermite interpolation between two values. A fuller explanation is in the docs linked but what this basically means is: 0.0 is returned if x < edge0 and 1.0 is returned if x > edge1. If x lies between edge0 and edge1 an interpolated value between 0.0 and 1.0 is returned.|

By using the returned value we can turn on or off color or blend colors. Ultimately we'll use `smoothStep()` but we'll start with `step()`.

The code to draw a rectangle with `step()` is in `glsl\rectstep.frag`. Open that file and read through it. It is heavily commented and that information is not repeated here. Once you have read through it open up the glsl-canvas and see the result.

Now of course we can take the same code and change the inputs to the `rect()` to draw a rectangle. And we can make multiple calls to draw multiple rectangles.

Open the `rectsmoothstep.frag` file to see both how `smoothStep()` works and how we can create multiple rectangles. You will see that we are drawing three rectangles and we end up with a fuzzy sort of H letter.

Now, clearly a refinement to reduce the amount of fuzziness at the edge could be made, or it could be made a parameter of the `rect()` function.

### Circles

The `glsl\circle.frag` file contains examples of drawing circles both with a hard and a fuzzy outline following the same convention as for rectangles. `circle()` draws a hard edged circle, while `smoothcircle()` draws one with fuzzy edges. They use the `step()` and `smoothstep()` functions respectively.

The only real difference here is the use of the `distance()` function. This function computes the Euclidean distance from a point to another point. The two points we will use are the current fragment's x,y coordinate and coordinate of the centre of the circle. The threshold of the `step()` or `smoothstep()` function is the radius of the circle.

Again the file is commented heavily with explanations.

### Semi-circles

`glsl\semicircle.frag` alters the circle code a little to only return a positive value if the current fragment's x coordinate is greater than the x coordinate of the center point. Obviously something more configurable could be done but this is all we need for HelloWorld.

Again there are hard and fuzzy edged variants. Note that the application of the threshold for x > centre.x is applied a bit differently in the `smoothsemicircle()` case. This `smoothstep(0.5, 0.55, point.x)` is multiplied by the result from the circle creation code. The result is every point with an x value > 0.55 is multiplied by 1, everything with an x value < 0.5 is multipled by 0 and thus removed, and every point in between is multiplied by a value between 0 and 1 leading a fuzzy end to the semi-circle.

### Lines

In this example there is one unique stroke in a letter - the angled leg of the R. Creating a thick line is simple enough - you just create a rectangle. But how to get it at the right angle. To do that we rotate it with a rotation matrix. Load up `line.frag` and you'll see a `rotate()` function which given an angle of rotation in radians returns a matrix that will perform that rotation. 

## Making Letters

Having figured out how to make basic shapes we can now combine them into a simple, and very blurry, font. We won't make a complete font, just H E L O W R D. There is very little to say about `letters.frag` that we have not already covered. It is just a matter of drawing straight lines of different lengths and circles or semicircles of different diameters. There is however the leg of the R. Having done the rotation we move the angled leg into position adjusting the x, y position. This could have been done with another matrix to do a translation operation, but for simplicity I just adjusted x and y directly.

`letters.frag` has all the smooth*() functions and then a function named for each letter. Then in `main()` we call each letter in a cycle that goes through the letters leaving each one disaplyed for a fixed amount of time. L of course gets two time units in the middle of `Hello`. The primary reason for doing this is to prove we have all the letters and to show how to animate something very simply.

## Bringing it into HaxeFlixel

Now we'll construct a FlxShader based on `letters.frag`. We'll do this in stages so that we can see and resolve the problems as we go along. The files for each stage are in `helloworld\lessonstages\stageX`. These files need to be copied to `source` as you read through the tutorial description below so you can run the code. Alternatively you can just read the files.

### Prepare a new HaxeFlixel Project

The first thing to do is to create a new HaxeFlixel Project. This is already done in this tutorial in the `helloworld` project directory. This is simply created using `flixel tpl -n helloworld`. There is no need for you to do this in this case as it is already done in the `tutorials\helloworld\helloworld` directory in the parasol repository.

Note, in the discussion below that fragment is used because it's technically what the fragment shader processes. For our purposes here it is synonymous with pixel.

### Running each version

If you want to build the application with the code for a particular stage copy the `stageX` files to `source` and then run the build and test the application. Make sure you copy all the files so that there is no inconsistency.

### Stage1

First we need to create a `LetterShader.hx` file which will be our FlxShader subclass, our shader, and a `LetterSprite.hx` which will be our demo sprite. In addition there is the regular `PlayState.hx` which we'll modify to create sprites and display them.

#### LetterShader.hx

To convert the GLSL `letters.frag` shader into a FlxShader we do the following:

   * take the GLSL shader from `letters.frag` and copy and paste the whole lot into a @:glFragmentSource macro just above the constructor,
   * remove the `#ifdef GL_ES` block
   * add a `#pragma header` directive in its place
   * remove the `u_resolution` and `u_time` uniforms and references to them in the code
   * add `uniform int u_letter` which is an integer identifying the letter to create. We cannot use a string as there are no string types in GLSL
   * add a Letter enum to this module to make it easier to create a LetterShader for each letter,
   * add code in `new()` to convert from the enum to the right integer and pass that into the `u_letter` uniform. This is done by assigning the integer as a single element array to `this.u_letter.value`.
   * in the `main()` function of the GLSL code itself replace `vec2  st = gl_FragCoord.xy/u_resolution.xy;` with `vec2 st = openfl_TextureCoordv.xy;`. This is important to understand. `gl_FragCoord.xy` is the x,y coordinate of the fragment being processed by the shader core running this instance of the shader. `u_resolution.xy` is the size of the overall x,y space. So `gl_FragCoord.xy/u_resolution.xy` gives the coordinate as a value of x and y between 0.0 and 1.0. This is useful in shaders because of the mathematical functions commonly used. However, `openfl_TextureCoordv.xy` has already been scaled to the range 0.0 to 1.0 so no division is required.
   * add `vec4 c = flixel_texture2D(bitmap, st);` to obtain the color information for the fragment we are processing. This will allow us to blend with that color rather than overwrite it.

#### LetterSprite.hx

`LetterSprite.hx` is a trivial sprite class which creates sprite positioned at x,y and with a graphic of size width and height on which to draw our shader-based letters and sets the background to a random FlxColor. It also sets the `FlxSprite.shader` field to a shader for the particular letter. The letter is chosen using the `Letter` enum. 

The shader modifies the red channel in the RGB color only. In addition the alpha value is set to 0.5 so we see a blending of the shader drawn letter which is just drawn on the sprite graphic.

#### PlayState.hx

`PlayState` is a very simple class which constructs an Array of `LetterSprites` to show the letters H E L L O W O R L D. The `computerLetterSpritePos()` function is a simple helper function to determine the correct placement of the letters. This helps keep `create()` uncluttered.

#### Testing The First Cut

So now copy the `helloworld\lessonstages\stage1` files to `helloworld\source` and run the build and run the code.

What do you notice ?

Everything is basically ok, except .... the text is upside down. What happened ?

This is very important to understand as it will affect your shaders and will manifest in various ways which will not always be immediately obvious.

In a normal computer display the origin point (0,0) is the top left and x increases to the right and y increases as you go down the screen.

```
(0,0)
      ------------------------------------ x (FlxSprite.width)
      |
      |
      |
      |
      |
      |
      |
      |
      
      y (FlxSprite.height)
```

This is not how graphing works in mathematics. In regular mathematics (0,0) is in the bottom left and y increases as you go up. This is also how it works in GLSL. In addition these will normally be scaled so that FlxSprite.width and FlxSprite.height both = 1.0. This does not alter the aspect ratio of the sprite but x and y are floating point numbers not integers in GLSL. So the screen coordinates in GLSL look like this:


```      
      y (1.0)

      |
      |
      |
      |
      |
      |
      |
      |
      ------------------------------------ x (1.0)
(0,0)
```

As a consequence of this flipping of the y axis direction the letters are now upside down. In order to fix this we need to convert the y coordinate from the way HaxeFlixel views it to the way GLSL views it.

The solution is to transform the y axis in this way:

```
            st.y = 1.0-st.y;
```

You can add this after:

```
            vec2 st = openfl_TextureCoordv.xy;
```

### Stage 2

In this section we'll add a FlxTween to spin the letters and demonstrate that the shader draws on the sprite graphic relative to the 0,0 location and angle of the sprite.

The code for this is in `helloworld\lessonstages\stage2`.

What this stage demonstrates is the flipping of the y axis, the letters are now upright. Also that they are oriented relative to the FlxSprite they are drawn on, they rotate with the sprite. In addition, we see a variation in the color of the letters as we are combining the background tile color with the shader letter color which is basically full intensity red.

The primary change here is the adding of code to `PlayState.hx` to add tweens to rotate the letter sprites.

#### PlayState.hx

We add an update function with support to start and stop spinning the letters and to reset to the initial state.

```
		// Start or cancel tweens to spin the letters
		if (FlxG.keys.justReleased.S)
		{
			if (_spinningTweens == null)
			{
				// Starting spinning
				_spinningTweens = new Array<FlxTween>();
				for (l in _letters)
				{
					// 1 second per full rotation, repeating until stopped
					_spinningTweens.push(FlxTween.angle(l, l.angle, l.angle + 360, 1, {type: LOOPING}));
				}
			}
			else
			{
				// Cancel spinning and destroy tweens
				stopSpinning();
			}
		}
```

We add a separate function to stop the spinning because it's called in two places, in the S key handler and in the R one which resets the state to the initial setup.

```
	/**
	 * Helper function to stop the tweens
	 */
	private function stopSpinning():Void
	{
		for (t in _spinningTweens)
		{
			t.cancel();
		}
		_spinningTweens = null;
	}

```

We also add a simple description of keys that start and stop the spinning and reset to the initial state.

If you copy the `helloworld\lessonstages\stage2` code to `source` you can run this and see the letters rotating with the sprites when you hit S.

### Stage 3

Now we'll add an update() function to the shader to pass the current angle of rotation of the sprite to the shader so that the shader code can compensate for the sprite rotation. This will allow the letters to stay oriented correctly while the colored square spins around them. This will show two things. How to do an update on a shader on a periodic basis and how angles are handled in GLSL versus how they are handled in HF. It will also give us another example of a rotation matrix. Let's walk through the changes. The code is in `helloworld\lessonstages\stage3`.

#### LetterShader.hx

First we add a `uniform float u_angle` to our GLSL code. We initialize it in the `LetterShader.new()` like this:

```
		this.u_angle.value = [0.0];
```

Then we add code to use the angle to rotate the letter backwards to compensate for the sprite angle. We add this just after we have gotten the `st` x,y coordinate.

```
            st = st - vec2(0.5);
            st = rotate2d(u_angle) * st;
            st = st + vec2(0.5);
```

This bears a little explanation. The rotation is to be about the origin (0,0) but this point is at the bottom left of the graphic. So we first move it to the center of the graphic which is (0.5,0.5). Then we rotate and then we translate back to the original origin point. You can experiment with removing this to see what will happen without the translation.

Next we add an `update()` function to the shader class which can be called from `LetterSprite.update()`.

```
	/**
	 * Update shader variables as needed
	 * @param angle the angle of the sprite, in degrees
	 */
	public function update(angle:Float)
	{
		this.u_angle.value = [angle];
	}
```

#### LetterSprite.hx

Now we add an `update()` function to the `LetterSprite` which will call the shader `update()` function:

```
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (shader != null)
		{
			cast(shader, LetterShader).update(-angle);
		}
	}
  ```

Note the following things:

   * that we will only update the shader if there is one,
   * that we cast the shader to a `LetterShader` type. 
      * this is necessary because there is no update function on FlxShader for us to override
      * this is only safe because we know that this is the only type of shader that it would be
   * that we set the angle to -angle because we want to reverse the effect of the sprite rotation
 
Now, if you were to run the code with these modifications you would find that the letters rotate certainly, but they rotate very much faster than the sprite rather than compensating for the rotation of the sprite. There are two problems here. The first is because HaxeFlixe and GLSL use different units for angle. In HF angle of a sprite is in degrees. In GLSL angles are expressed in radians. And while there are 360 degrees in a circle there are only 2 * PI (about 6.28) radians in circle. So we need to adjust the degrees angle to radians. You can do this anywhere you like but it probably makes sense to do it in `LetterShader.update()`. This will put it in a central place and you can still keep all the HF code using degrees. The updated `update()` function looks like this:

```
	public function update(angle:Float)
    {
        // Convert angle from degrees to radians
        this.u_angle.value = [angle * Math.PI / 180];
    }
```

Now this looks not much better. The letter is now rotating in the same direction as the sprite but faster than it. If you look closely it will be seen that the letter is rotating about twice as fast. This is a clue to what is happening. The negative angle that we passed in is being added to the rotation angle of the sprite. Why is that ?

This is related to the y-axis flip. If for example I comment out:

```
            // st.y = 1.0-st.y;
```

Then you will get the right rotation but the letters will be upside down again. So although we want to have a negative rotation of the shader-drawn letter by the sprite rotation angle if we pass `-angle` will get more rotation. So the fix is simple - just pass the angle as it is. The question is, whether this is confusing and where should you convert from a negative angle to a positive. Again the best place would be inside the shader `update()` function from a usability standpoint. Then in your HaxeFlixel code you can just do what makes logical sense in that environment. However it means that you are using two negation operations which is, apart from readability, rather pointless. My own feeling is that the usability of the double negative outways the redundancy and that the performance cost is negligible, so I'll put it in the shader `update()`. The final correct `update()` function is:

```
	public function update(angle:Float)
    {
        // Convert angle from degrees to radians
        // Take the negative of the angle to compensate for the y-axis flip
        this.u_angle.value = [-angle * Math.PI / 180];
    }
```

Also remember to make sure the y-axis flip code is reenabled.

```
            st.y = 1.0-st.y;
```

### Conclusion

At this point we've seen how to construct basic shaders and bring them into HaxeFlixel. We have also seen issues with axes and scaling and how they are dealt with. Various things could be done as next steps.

One example is the rotation matrix. It is computed in every shader core in GLSL but we could compute it once in the host program on the CPU and pass it as a uniform to the shader program. You would just need to create a `mat2x2` uniform in the glsl code and convert the glsl `rotate2d()` function to Haxe.

## References

Installation instructions and documentation can be found at the following links:

   * [Haxe](https://haxe.org)
   * [HaxeFlixel](https://haxeflixel.com/)
   * [VSCode](https://code.visualstudio.com/)
   * [glsl-canvas](https://marketplace.visualstudio.com/items?itemName=circledev.glsl-canvas)