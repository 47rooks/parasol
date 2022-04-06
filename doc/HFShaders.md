# Shaders

- [Shaders](#shaders)
  - [Some Background](#some-background)
    - [Dimensions](#dimensions)
    - [Y-Axis Orientation](#y-axis-orientation)
  - [HaxeFlixel Shaders](#haxeflixel-shaders)
    - [Vertex Shader Variables](#vertex-shader-variables)
    - [Fragment Shader Variables](#fragment-shader-variables)
  - [flash.display package shader support](#flashdisplay-package-shader-support)
  - [A Quick HaxeFlixel Example](#a-quick-haxeflixel-example)
    - [FlxShader](#flxshader)
    - [Putting the GLSL Code into your FlxShader](#putting-the-glsl-code-into-your-flxshader)
      - [Difficulties](#difficulties)
    - [Passing Data From the Host Program to the Shader Program](#passing-data-from-the-host-program-to-the-shader-program)
  - [Developing GLSL Shader Code](#developing-glsl-shader-code)
    - [Converting GLSL Code to HaxeFlixel GLSL Code](#converting-glsl-code-to-haxeflixel-glsl-code)
      - [An Example Conversion](#an-example-conversion)
    - [Debugging HF Shader Code](#debugging-hf-shader-code)
  - [Appendices](#appendices)
    - [A. The OpenGL pipeline](#a-the-opengl-pipeline)
    - [B. Glossary](#b-glossary)
    - [C. References](#c-references)

## Some Background

The first thing to understand is what a shader is. A shader is a program that runs on the video card GPUs rather than on the computer's CPU. There is significant performance benefit to be had from running graphics code on the GPUs. They are specially designed for graphics and optimized for operations that are commonly used in graphics. In addition there are large numbers of them. A specific programming language is used to write shaders. Within OpenGL this is called GLSL (Graphics Language Shader Language). 

The second thing to grasp is that when you write a program that uses shader programs you are writing two programs that work together to produce the desired effects. The first is the program that runs on the CPU. This might be in C#, Java, Haxe, or any number of other languages. The second is in the shader programming language. The first program is called the OpenGL program in OpenGL literature. I tend to refer to it as the host program. The second is the shader program, the GLSL program.

Thirdly, the GLSL programs are inherently parallel in execution but limited in scope. A GLSL program generally cannot see the whole model or all pixels. It can be done but in general the way they run is by doing work on a small part of the whole. Vertex shaders only see the vertices associated with the primitve they are working on. Fragment shaders only work on a single pixel and produce colour for that pixel. Now strictly, one can pass more information to the individual shader programs so they can have a more global context. But it is often completely unnecessary. This isolation into parts allows very great parallelism to be deployed with a consequent speed up in processing.

Offloading processing to the GPUs gains performance in two ways, getting work off the CPU and processing GPU programs in parallel.

At the end of this document is a description of the OpenGL rendering pipeline. This pipeline specifies points where customized programs may be inserted to process various stages in the rendering of a model into a 2D dimensional screen image. Each program piece inserted into these points is a shader. For our purposes though there are really only two stages that are available in HaxeFlixel (HF) and OpenFl - the vertex shader and the fragment shader, the first and last modifiable stages in the pipeline. The others are not exposed and for 2D work there likely is not much call for them. In truth when people talk about shaders in the HF context, they mostly mean a fragment shader whose job is basically to determine the color of pixels. But the use of fragment shaders can produce a wide variety of effects, which look like much more than choosing pixel colors but fundamentally that is all they are doing.

Finally all OpenGL and OpenGL GLSL APIs are documented at https://www.khronos.org/, which maintains open standards for 3D graphics and related functions. Refer to [References](#c-references) for links. 

### Dimensions

GLSL programs use many functions that operate on floating point numbers in the range 0.0 to 1.0. If a point is passed to a shader as an integer it is commonly divided down by the resolution of the bitmap to result in a float between 0 and 1. You will see this verry often in shader code where you see something to this effect:

```
vec2 st = gl_FragCoord.xy / u_resolution;
```

This then allows comparison of value with the output of such functions as sin and cos, easy scaling for repitition based algorithms and so on.

When a shader is attached to a sprite by setting `sprite.shader = MyShader`, the shader operates on the graphic in the sprite. All drawing is relative to that graphic's dimensions. 0,0 is the bottom left of the shader drawing space.

### Y-Axis Orientation

In 2D computer displays the top left corner is usually 0,0 and Y increases as you go down the screen. Shaders operate in a way more natural to mathematics and use the bottom left corner as 0,0 and Y increases as you go up the screen. Forgetting this can lead to unexpectedly unside down results in your shader.

## HaxeFlixel Shaders

HF and OpenFl shaders are OpenGL GLSL shaders. They can be applied to sprites and cameras in HF.

HF itself does not have extensive shader support. FlxSprite can have a shader and a camera can have a shader. These shaders are ultimately instances of openfl.display.Shader. This can only provide vertex and fragment shading support. As noted above, access to other pipeline shaders is not available at this level. 

When a FlxShader is compiled a vertex shader is provided by the library even if your code does not provide one. It defines a number of attributes, varyings and uniforms. For the fragment shader stage it provides a number of varyings and uniforms and a helper function to access texture data. This is like the GLSL texture2D function. It is called flixel_texture2D and will handle certain HF/OpenFl specific things that texture2D would be unaware of, specifically color transforms and transforms.

In the shader variables tables below the OpenFl variables originate from openfl.display.GraphicsShader, and the HF ones originate in flixel.graphics.tile.FlxGraphicsShader. The values for these variables at runtime come from OpenGLRenderer and FlxDrawQuadsItem respectively.

### Vertex Shader Variables

FIXME Need to complete and refine these definitions when I've tested more.

|Variable type and name|Description|
|-|-|
|**OpenFl Layer Variables**|
|*Uniforms*|
|uniform mat4 openfl_Matrix||
|uniform bool openfl_HasColorTransform|If true the DisplayObject has a ColorTransform.|
|uniform vec2 openfl_TextureSize||
|*Vertex Shader Input Attributes*|
|attribute float openfl_Alpha|Passed to openfl_Alphav. If HF hasColorTransform is true this combined with alpha.|
|attribute vec4 openfl_ColorMultiplier|Passed to openfl_ColorMultiplierv. If HF hasColorTransform is true this is overriden by colorMultiplier.|
|attribute vec4 openfl_ColorOffset|Passed to openfl_ColorOffsetv.  If HF hasColorTransform is true this is overriden by colorOffset.| 
|attribute vec4 openfl_Position||
|attribute vec2 openfl_TextureCoord||
|*Vertex Shader Output Varyings*|
|varying float openfl_Alphav|From the corresponding input, openfl_Alpha.|
|varying vec4 openfl_ColorMultiplierv|From the corresponding input, openfl_ColorMultiplier.|
|varying vec4 openfl_ColorOffsetv|From the corresponding input, openfl_ColorOffset.|    
|varying vec2 openfl_TextureCoordv|From the corresponding input, openfl_TextureCoord.|
|**HaxeFlixel Layer Variables**|
|attribute float alpha|FlxSprite alpha value.|
|attribute vec4 colorMultiplier|FlxSprite color multiplier from ColorTransform.|
|attribute vec4 colorOffset|FlxSprite color offset from ColorTransform.|
|uniform bool hasColorTransform|If true the FlxSprite has a ColorTransform.|

### Fragment Shader Variables

|Variable type and name|Description|
|-|-|
|**OpenFl Layer Variables**|
|*Uniforms*|
|uniform bool openfl_HasColorTransform|Whether the DisplayObject has a ColorTransform or not. See https://api.openfl.org/openfl/geom/ColorTransform.html|
|uniform vec2 openfl_TextureSize|This should be the bitmap size in pixels.|
|uniform sampler2D bitmap|The sprite bitmap data. This is the FlxSprite.pixels field. See https://api.haxeflixel.com/flixel/FlxSprite.html|
|*Vertex Shader Output Varyings*|
|varying float openfl_Alphav|The alpha value of the DisplayObject.|
|varying vec2 openfl_TextureCoordv|The fragment coordinate scaled to 0.0 -> 1.0. There is no need to scale this manually.|
|varying vec4 openfl_ColorMultiplierv|The values of the ColorTransform multipliers if there is one.|
|varying vec4 openfl_ColorOffsetv|The values of the ColorTransform offsets if there is one.|
|**HaxeFlixel Layer Variables**|
|uniform bool hasTransform|This should indicate that there is a transform attached to this sprite.|
|uniform bool hasColorTransform|Whether the FlxSprite has a ColorTransform. See https://api.openfl.org/openfl/geom/ColorTransform.html|

The fragment shader also has a helper function to obtain the texture value (color and opacity) at a given coordinate. This is necessary so that any color transform can properly affect the value. If one simply called OpenGL's texture2D() function it could return the wrong value if there was a color transform in effect. The HaxeFlixel alternative is called flixel_texture2D (It relies on the *Transform uniforms). It has this signature:

```
vec4 flixel_texture2D(sampler2D bitmap, vec2 coord)
```

## flash.display package shader support

The flash.display package provides a number of classes devoted to shading - Shader, ShaderData, ShaderParameter, ShaderParameterType and ShaderPrecision.

FIXME more on this later if it's helpful.

## A Quick HaxeFlixel Example

### FlxShader

In Haxe, and hence HF, the host program (the OpenGL program) is the HF game code. The GLSL shader program is embedded in a compiler macro in a subclass of FlxShader in this way:

```
class PulsingColorShader extends FlxShader
{
    @:glFragmentSource('
        #pragma header
    
        uniform float u_time;
    
        vec3 colorA = vec3(0.149,0.141,0.912);
        vec3 colorB = vec3(1.000,0.833,0.224);
    
        void main() {
            vec3 color = vec3(0.0);
                
    
            float pct = sin(u_time) + 0.5;
    
            // Mix uses pct (a value from 0-1) to
            // mix the two colors
            color = mix(colorA, colorB, pct);
    
            gl_FragColor = vec4(color,1.0);
        }
    ')
    public function new()
    {
        super();
        // Create u_time variable to supply the uniform the shader needs
        this.u_time.value = [0.0];
    }

    /**
     * Update shader variables as needed
     * @param elapsed the time since the last update
     */
    public function update(elapsed:Float)
    {
    	this.u_time.value[0] += elapsed;
    }
}
```

### Putting the GLSL Code into your FlxShader

There are a number of macros that setup the GLSL code to be passed to the GPU by OpenGL code lower in the library stack. The two most significant are:
```
@:glVertexSource
@:glFragmentSource
```
Both take strings of the actual GLSL source.

Note, `#pragma header` statements should be included in the text. These ensure that the OpenFl and HF code blocks that set up the uniforms and varyings described in the tables above are included in your shader program. Without this you will not have access to those variables.

#### Difficulties

There is an unfortunate implication of this approach. You cannot easily create the GLSL code at runtime. I am still investigating if there are ways to do this. One reason to need to do this relates to the fact that for-loop limit values must be constants in the code. GLSL does not accept a variable in that position. If you have a need for a variable loop limit other tricks have to be employed, such as using a very large constant value in the loop and putting an if statement inside the loop which checks the real limit from a uniform variable.

If you need a variable length array this is also a problem. OpenGL supports buffer objects of varying size but creating such a complex object from HF via OpenFl's macros is not possible. You could of course create an array of a size greater than the most you would need and then put a special value in the last element. You could then have a for-loop up to the maximum with code to break out as soon as the special value is found. Of course this wastes memory and it may not always be easy to pick an appropriate special value.

OpenFl does not support passing array uniforms as far as I can tell. This rather makes the above objection moot. The best you could do is to use the matrix4x4 ShaderParameterType and get 16 values passed into a shader.

### Passing Data From the Host Program to the Shader Program

All data given to the shader program comes ultimately via the host program. If you look through the OpenGL API you will find there are many ways to pass data of various sizes and types to the shader program. In HF though this basically collapses down to member variables in your FlxShader subclass. When you define a uniform in your GLSL program compile-time macros will expose this as a member variable in your FlxShader subclass. You should not define a variable of the same name yourself as that will create an error at compile time.

If you look at the PulsingColorShader shader above you will see:

```
uniform float u_time
```
This variable is a assigned a value of 0.0 in the constructor like this, but there is no field defined in the class with this name:

```
	this.u_time.value = [0.0];
```
These are always done using variable.value and assigning an array of values, which may be just one value. This value may be updated with elapsed time from the FlxState update() function by calling a function on the PulsingColorShader that updates this value:

```
	public function update(elapsed:Float)
	{
		this.u_time.value[0] += elapsed;
	}
```

This approach may be followed for any data that needs to be updated by host program (game) state and made known to the GLSL program.

## Developing GLSL Shader Code

The easiest way to develop shader code itself is to use glsl-canvas in VSCode, or use Shadertoy, or some such similar service. These allow you to focus on the fragment shader directly and avoid having to deal with making uniforms available to the shader program and so on. However, you then end up with code that must be converted in some small ways to run inside a FlxShader.

### Converting GLSL Code to HaxeFlixel GLSL Code

Generally, other frameworks like Shadertoy and glsl-canvas will have naming conventions for certain key uniforms. You will need to change these names to match whatever HF/OpenFl use or what you yourself will use in your FlxShader subclass. Failing to do this correctly will result in a non-functioning shader which produces no effect.

#### An Example Conversion

I needed a shader to draw a line across a sprite and fill below it.
In GLSL tested in glsl-canvas it looked like this:
```
1   #ifdef GL_ES
2   precision mediump float;
3   #endif
4
5   uniform vec2 u_resolution;
6
7   void main() {
8       vec2 points[2];
9       points[0] = vec2(0.0, 0.25);
10      points[1] = vec2(1.0, 0.75);
11    
12      vec2 st = gl_FragCoord.xy/u_resolution;
13
14      // Compute slope
15      vec2 pt1 = points[0];
16      vec2 pt2 = points[1];
17      float run = pt2.x - pt1.x;
18      float slope = (pt2.y - pt1.y) / run;
19      vec3 color = vec3(0);
20      float y_interp = pt1.y + (st.x - pt1.x) * slope;
21      if (st.y < y_interp) {
22          color = vec3(0.,0.,1.);
23      }
24
25      // Compute whether I am above or below line and set color accordingly
26      gl_FragColor = vec4(color, 1.0);
27  }
```

What needs to be converted, and how ?

The first block
```
#ifdef GL_ES
precision mediump float;
#endif
```
is meaningful and required by glsl-canvas but a slightly different piece of code is inserted by OpenFl. So it is simply dropped. In order to have this and the OpenFl/HF uniforms, varyings and support function, a `#pragma header` is added. The uniform u_resolution is not required in HF shaders because the openfl_TextureCoordv value is already normalized to 0->1, so I we do not need to normalize the xy coordinate in the shader. So line 12 is also removed.

Now, lines 8-10 represent hardcoded start and endpoints. The start at (0.0, 0.25) and the end at (1.0, 0.75). So the line starts on the left extreme and goes to the right extreme. Now, my application requires that I be able to set this value from HF. So these lines are removed and new uniforms for the start and end points are added at L4,5 below. L12 above is changed to L8 in the HF shader below.

The reason uniforms are used is so that all fragment shader invocations at each pixel can figure out whether to paint the pixel a particular color or not. To determine that, they need to be able to compute the slope between the start and end points. They then compute the y value at their own x value and determine whether their own y value is above or below that value. If below they paint it blue. If above they paint it black.

Now the problem with this is that whether their own y value is above or below depends upon the direction of y. So while this portion of the code is used in both glsl-canvas and HF, one small change is required. Line 21 must flip the comparison from < to >.

The resulting HF shader code looks like this:

```
1     @:glFragmentSource('
2         #pragma header
3
4         uniform vec2 u_point1;
5         uniform vec2 u_point2;
6
7         void main() {
8             vec2 st = openfl_TextureCoordv.xy;  // Note, already normalized
9
10
11             // Compute slope
12             float run = u_point2.x - u_point1.x;
13             float slope = (u_point2.y - u_point1.y) / run;
14             vec3 color = vec3(0);
15             float y_interp = u_point1.y + (st.x - u_point1.x) * slope;
16
17             // Compute whether I am above or below line and set color accordingly
18             if (st.y > y_interp) {
19                 color = vec3(0.,0.,1.);
20             }
21            
22             // Output the color
23             gl_FragColor = vec4(color, 1.0);
24        }
25    ')
```

Of course, the precise changes required will vary, and your HF code will have to set the uniforms and attributes, if any.

### Debugging HF Shader Code

Once converted the shader may not run due to some conversion mistake or other reason. To debug this add a `-v` flag to your `lime test` or `lime run` command to turn on GLSL compiler error reporting. Your code is not actually compiled until fairly late, at runtime. This makes sense because the code does not need to be compiled if it isn't actually used.

Debug output will show you GLSL compiler errors raised by your code, and while it will include your code in the error message there are no line numbers attached to your code. But there are on the messages and you can take the dumped shader code in the error message and figure out which line is at fault. Remember that there will be additional HF/OpenFl code added to your code because of the pragmas. So you cannot just compare to your original code. Here is an example of a fragment shader throwing errors.

```
Uncaught exception: [openfl.display.Shader] ERROR: Error compiling fragment shader
0(68) : warning C7505: OpenGL does not allow swizzles on scalar expressions
0(69) : warning C7011: implicit cast from "float" to "vec2"
0(70) : warning C7011: implicit cast from "float" to "vec2"
0(71) : warning C7011: implicit cast from "float" to "vec2"
0(72) : warning C7011: implicit cast from "float" to "vec2"
0(78) : warning C7623: implicit narrowing of type from "vec2" to "float"
0(79) : warning C7623: implicit narrowing of type from "vec2" to "float"
0(81) : warning C7623: implicit narrowing of type from "vec2" to "float"
0(68) : error C1008: undefined variable "u_numpoints"

#ifdef GL_ES
                                #ifdef GL_FRAGMENT_PRECISION_HIGH
                                precision highp float;
                                #else
                                precision mediump float;
        ...
        ...
        ...
```

## Appendices

### A. The OpenGL pipeline 

A key concept to understand is the OpenGL pipeline. Suffice to say this note is not the place to go into that in any detail. For a full description refer to the OpenGL Superbible, or the OpenGL specification. But a sketch here will be helpful.

The rendering pipeline in GL takes a fixed flow through various stages from the point the host program passes some kind of geometry to it until it is rendered on-screen. Many of the stages are pluggable taking various pieces of a shader program. Each stage has a specific function in the progression from model to rendered screen image. Not all the stages are exposed in HF/OpenFl.

   |Stage|Fixed|Required|Purpose|Main Input|Main Output|Runs Once Per|
   |-----|-|-|------|-----|------|----|
   |*Vertex Fetch*|*Y*||*Also called vertex pulling, obtains the vertex information from the host program.*|
   |Vertex Shader|N|Y|The only required stage. Sets the position of the vertex|Vertex attrs|Patches|Vertex|
   |Tesselation Control Shader|N|N|Provide parameter to the tesselator controlling tesselation|Patches|Tesselation control factors, position and per patch varyings|Patch|
   |*Tesselator*|*Y*||*Performs the actual tesselation converting input patches to output primitives.*|
   |Tesselation Evaluation Shader|N|N|Runs after the tesselation has been done. Because it executes once per vertex expensive operations are best avoided here.|Vertices|Primitives|Vertex|
   |Geometry Shader|N|N|The only that can directly produce new arbitrary vertices or primitives, modifying the geometry of the received primitive.|Primitive|Point, Line-Strips, Triangle-Strips|Primitive|
   |*Rasterizer*|*Y*||*Rasterization converts primitives and bitmaps into pixel fragments.*|
   |Fragment Shader|N|N|Determine the color for the fragment|Fragment|Color|Fragment|
   |*Framebuffer*|*Y*||*The default framebuffer usually represents a window or display device.*|

Everything before the Rasterizer is considered front end, and after the backend of the pipeline.

   |Stage|Description|
   |-|-|
   |Compute Shader|Perform computation on GPU. Not part of rendering pipeline, rather a separate pipeline for computation.|

### B. Glossary

|Term|Definition|
|-|-|
|Attributes|Per-vertex inputs to the vertex shader. Such things will include color, position, normal direction, texture coordinates.|
|Control Points|Inputs to the tesselation stages. These basically are vertices coming out of the Vertex shader, but called by another name. |
|Fragment|For practical purposes a pixel. However it is properly described as something that might contribute to a pixel's color. It might also be culled out, for example due something in front it.|
|Patch|A high-order primitive which will be breaking down by tesselation to triangles.|
|Primitive|The basic unit of rendering - a group of vertices. The three basic types are point, lines, and triangles, though there are many others.|
|Varyings|A varying (varying variable) is an output of vertex shader which is passed read-only to a fragment shader. It is interpolated from the vertexes that make up the fragment.|
|Uniform|A uniform takes the same value for all shader invocations. They may be updated frame to frame but within a single frame they are constant.|

### C. References

[OpenGL Superbible](https://www.amazon.com/OpenGL-Superbible-Comprehensive-Tutorial-Reference/dp/0672337479)

[The OpenGL Shading Language](https://www.khronos.org/registry/OpenGL/specs/gl/GLSLangSpec.4.50.pdf)

[Khronos Group OpenGL 4.5 API Reference Pages](https://www.khronos.org/registry/OpenGL-Refpages/gl4/)

[Khronos Group OpenGL Reference Pages](https://www.khronos.org/registry/OpenGL-Refpages/)

[The Book of Shaders](https://thebookofshaders.com/)

[Richard Bray's video](https://www.youtube.com/watch?v=3sI9uip7QS0&list=PLiKs97d-BatF4rKLGxxco0Xne9fgs6aUM)

[Shader Toy](https://www.shadertoy.com/howto)

