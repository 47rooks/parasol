# Hello World

- [Hello World](#hello-world)
  - [The Plan](#the-plan)
  - [The Development Environment](#the-development-environment)
    - [GLSL](#glsl)
  - [Some GLSL Basics](#some-glsl-basics)
  - [Simple Shapes](#simple-shapes)
    - [Rectangles](#rectangles)
    - [Circles](#circles)
    - [Semi-circles](#semi-circles)
    - [Lines](#lines)
  - [Making Letters](#making-letters)
  - [Bringing it into HaxeFlixel](#bringing-it-into-haxeflixel)

Every new programming language tutorial needs a "Hello World!".
This is such a tutorial for HaxeFlixel (HF) shaders.

## The Plan

As this will be done with a fragment shader we don't have any geometry to work with. Instead we will "paint" the letters by setting colors for pixels in the right place.

To keep the shapes simple we'll use a very blocky style, fixed width font with no ornamentation. This means rectangles and circles and semi-circles.

## The Development Environment

### GLSL

I'll use VSCode with the glsl-canvas plugin to develop the basic shader code. (You could use other tools if you are familiar with them but you may need to tweak the shader code.) So go ahead and install both now if you do not have them. It is assumed you also have a Haxe and HaxeFlixel installation that works. Some version of Haxe 4.x or above should be fine. I used 4.2.4. HaxeFlixel can be any reasonably current version, 4.10 in my case.

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

The code to draw a rectangle with `step()` is in `tutorials\helloworld\glsl\rectstep.frag`. Open that file and read through it. It is heavily commented and that information is not repeated here. Once you have read through it open up the glsl-canvas and see the result.

Now of course we can take the same code and change the inputs to the `rect()` to draw a rectangle. And we can make multiple calls to draw multiple rectangles.

Open the `rectsmoothstep.frag` file to see both how `smoothStep()` works and how we can create multiple rectangles. You will see that we are drawing three rectangles and we end up with a fuzzy sort of H letter.

Now, clearly a refinement to reduce the amount of fuzziness at the edge could be made, or it could be made a parameter of the `rect()` function.

### Circles

The ``tutorials\helloworld\glsl\circle.frag`` file contains examples of drawing circles both with a hard and a fuzzy outline following the same convention as for rectangles. `circle()` draws a hard edged circle, while `smoothcircle()` draws one with fuzzy edges. They use the `step()` and `smoothstep()` functions respectively.

The only real difference here is the use of the `distance()` function. This function computes the Euclidean distance from a point to another point. The two points we will use are the current fragment's x,y coordinate and coordinate of the centre of the circle. The threshold of the `step()` or `smoothstep()` function is the radius of the circle.

Again the file is commented heavily with explanations.

### Semi-circles

`tutorials\helloworld\glsl\semicircle.frag` alters the circle code a little to only return a positive if the current fragment's x coordinate is greater than the x coordinate of the center point. Obviously something more configurable could be done but this is all we need for HelloWorld.

Again there are hard and fuzzy edged variants. Note that the application of the threshold for x > centre.x is applied a bit differently in the `smoothsemicircle()` case. This `smoothstep(0.5, 0.55, point.x)` is multiplied by the result from the circle creation code. The result is every point with an x value > 0.55 is multiplied by 1, everything with an x value < 0.5 is multipled by 0 and thus removed, and every point in between is multiplied by a value between 0 and 1 leading a fuzzy end to the semi-circle.

### Lines

In this example there is one unique stroke in a letter - the angled leg of the R. Creating a thick line is simple enough - you just create a rectangle. But how to get it at the right angle. To do that we rotate it with a rotation matrix. Load up `line.frag` and you'll see a `rotate()` function which given an angle of rotation in radians returns a matrix that will perform that rotation. 

## Making Letters

Having figured out how to make basic shapes we can now combine them into a simple, and very blurry, font. We won't make a complete font, just H E L O W R D. There is very little to say about `letters.frag` that we have not already covered. It is just a matter of drawing straight lines of different lengths and circles or semicircles of different diameters. There is however the leg of the R. Having done the rotation we move the angled leg into position adjusting the x, y position. This could have been done with another matrix to do a translation operation, but for simplicity I just adjusted x and y directly.

`letters.frag` has all the smooth*() functions and then a function named for each letter. Then in `main()` we call each letter in a cycle that goes through the letters leaving each one disaplyed for a fixed amount of time. L of course gets two time units. The primary reason for doing this is to prove we have all the letters and to show how to animate something very simply. This will carry over into more complex things when we bring this into HaxeFlixel.

## Bringing it into HaxeFlixel

Now we computed this rotation matrix in every shader core in glsl-canvas but we can now compute it once in the host program on the CPU and pass it as a uniform to the shader program.

