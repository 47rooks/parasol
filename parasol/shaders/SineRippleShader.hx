package parasol.shaders;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.NumTween;
import haxe.ValueException;

private typedef RippleProperties =
{
	/**
	 * The elapsed time of this ripple, since it started.
	 */
	var time:Float;

	/**
	 * The speed of the radiating of the ripple out from the center. Larger numbers as faster.
	 */
	var speed:Float;

	/**
	 * The frequency of the ripples, the larger the number the more ripple per unit distance.
	 */
	var frequency:Float;

	/**
	 * The initial amplitude at the point of impact. This value seeds the amplitude value below.
	 */
	var initialAmplitude:Float;

	/**
	 * The current amplitude at he impact point. This value is the initialAmplitude times the decay coefficient.
	 */
	var amplitude:Float;

	/**
	 * The damping value dampens the ripple at a distance from the center.
	 * The higher the value the less effect the ripple has at distance.
	 */
	var damping:Float;

	/**
	 * The impact x coordinate.
	 */
	var startX:Float;

	/**
	 * The impact y coordinate.
	 */
	var startY:Float;

	/**
	 * The index determines the offset into the uniforms to use to pass the shader parameters
	 * for this ripple.
	 */
	var uniformIdx:Int;

	/**
	 * True indicates this ripple (index) is in use. As only 16 may exist concurrently this is
	 * used to indicate active or inactive ripple.
	 */
	var inUse:Bool;
}

/**
 * The SineRippleShader creates a ripple effect using a modified sinusoid. Coeffecients of the various
 * parts of the equation permit modification of the frequency of the ripples, the speed at which they radiate
 * from the center, the center or point of impact that starts the ripple, the amplitude at the point of impact,
 * the damping of the ripple effect at greater distances from center.
 * 
 * Up to 16 ripples may be started at a time using this shader. Each may have its own set of configuration of
 * coefficients.
 * 
 * The constructor provides the initial coefficient values. Calling start will start a ripple at a specific
 * location with the amplitude specified using these coefficient values. If the coefficients are then changed 
 * and another ripple is started it will use the updated coefficients.
 */
class SineRippleShader extends FlxShader
{
	/**
	 * This algorithm is derived from Adrian Boeing\'s description at
	 *   http://adrianboeing.blogspot.com/2011/02/ripple-effect-in-webgl.html.
	 * 
	 * The description is interesting concerning the Sombrero function but the code
	 * does not actually implement one as far as I can tell. Rather it implements a
	 * modified sinusoid. What I have below is based on that initial function and
	 * then modified to add tunable coefficients to the major parts of the function.
	 * 
	 * The basic effect is created by computing a distance from the fragment to the
	 * the centre of the ripple (where the impact occurred to start the ripple).
	 * This distance is then used to locate the texel to display at the current
	 * fragment\'s location. This produces an appearance of refraction.
	 * 
	 * A number of parameters are provided and it is very easy to produce very strange
	 * effects if these get out of balance. Thus some factory are provided that setup
	 * parameters to produce a good result. 
	 */
	@:glFragmentSource('
        #pragma header

        uniform bool u_active;  // Is the shader actively drawing ripples
        
        uniform mat4 u_inUse;
        uniform mat4 u_time;
        uniform mat4 u_speed;
        uniform mat4 u_frequency;
        uniform mat4 u_amplitude;
        uniform mat4 u_damping;
        uniform mat4 u_originX;
        uniform mat4 u_originY;

        /*
         * Compute the ripple contribution at a fragment for a ripple centre.
         * 
		 * Parameters
		 *   fragPos - the position of the current fragment mapped to the range (-1, -1) to (1, 1)
		 *   rippleCentre - the position of the ripple\'s center point mapped to the range (-1, -1) to (1, 1)
		 *   frequency - the frequency of the ripples - higher values -> more ripples
		 *   time - the accumulated time in (seconds) since the ripple started
		 *   speed - the speed at which the ripples propagate outward
		 *   damping - the degree to which the ripples are muted at distance from the centre
		 *   amplitude - the initial amplitude of the ripple at the centre
		 * 
		 * Returns
		 *   the displacement to add to the fragment\'s position to get its texel from
         */
        vec2 computeDisplacement(vec2 fragPos, vec2 rippleCentre,
			float frequency, float time, float speed, float damping, float amplitude) {
            // Compute fragment distance from center of ripple
            float distToCentre = distance(rippleCentre, fragPos);
            vec2 direction = normalize(fragPos - rippleCentre);

            /* The following code causing the major ripples to flow out from the center but unfortunately
             * it does not to the lower end based on time ripple has been alive - it just uses a fixed
             * lower value (0.1). This results in a non-diminishing minimum until the amplitude takes effect.
             * Try adding some dynamic lower level based on lifetime.
             * Breadth of the rippling section is also not controllable.
             * And the speed of the radiation is not linked to the imapct.
             */
            float radiate = clamp(
                                smoothstep(time * speed - 0.2, time * speed + 0.2, distToCentre),
                                0.3, 1.0) *
                            clamp(
                                smoothstep((time * speed + 0.2) + 0.2,
                                           (time * speed + 0.2) - 0.2, distToCentre),
                                0.0, 1.0);
            vec2 uv = radiate * direction * cos(distToCentre * frequency - time * speed ) * amplitude / (1.0 + damping * distToCentre);
            return uv;
        }
        ' +
		#if desktop
		'
        void main() {
            vec2 offset = vec2(0.0);
            if (u_active) {
                int activeRipples = 0;
				// Compute fragment position relative to centre of texture
				// Also, get fragment position in range of -1.0 to 1.0
				vec2 relFragPos = -1.0 + 2.0 * openfl_TextureCoordv.xy;

				// Get contributions to the offset from all active ripples
				for (int i=0; i < 16; i++) {
                    int row = int(i/4);
                    int col = int(mod(float(i),4.0));
                    if (u_inUse[row][col] > 0.0) {
                        activeRipples++;
                        // Compute ripple centre relative to center of texture
                        // Scale to -1.0 to 1.0
                        vec2 relRippleCentre = vec2(u_originX[row][col], u_originY[row][col]) * 2.0 - 1.0;

						float frequency = u_frequency[row][col];
						float time = u_time[row][col];
						float speed = u_speed[row][col];
						float damping = u_damping[row][col];
						float amplitude = u_amplitude[row][col];
                        offset += computeDisplacement(relFragPos, relRippleCentre,
							frequency, time, speed, damping, amplitude);
                    }
                }
            }
            gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv.xy + offset);    
        }
		'
		#else
		'
		void main() {
            vec2 offset = vec2(0.0);
            if (u_active) {
                int activeRipples = 0;
				vec2 relFragPos = -1.0 + 2.0 * openfl_TextureCoordv.xy;
				if (u_inUse[0][0] > 0.0) {
					activeRipples++;
					vec2 relRippleCentre = vec2(u_originX[0][0], u_originY[0][0]) * 2.0 - 1.0;
					offset += computeDisplacement(relFragPos, relRippleCentre,
						u_frequency[0][0], u_time[0][0], u_speed[0][0], u_damping[0][0], u_amplitude[0][0]);
				}
				if (u_inUse[0][1] > 0.0) {
					activeRipples++;
					vec2 relRippleCentre = vec2(u_originX[0][1], u_originY[0][1]) * 2.0 - 1.0;
					offset += computeDisplacement(relFragPos, relRippleCentre,
						u_frequency[0][1], u_time[0][1], u_speed[0][1], u_damping[0][1], u_amplitude[0][1]);
				}
				if (u_inUse[0][2] > 0.0) {
					activeRipples++;
					vec2 relRippleCentre = vec2(u_originX[0][2], u_originY[0][2]) * 2.0 - 1.0;
					offset += computeDisplacement(relFragPos, relRippleCentre,
						u_frequency[0][2], u_time[0][2], u_speed[0][2], u_damping[0][2], u_amplitude[0][2]);
					}
				if (u_inUse[0][3] > 0.0) {
					activeRipples++;
					vec2 relRippleCentre = vec2(u_originX[0][3], u_originY[0][3]) * 2.0 - 1.0;
					offset += computeDisplacement(relFragPos, relRippleCentre,
						u_frequency[0][3], u_time[0][3], u_speed[0][3], u_damping[0][3], u_amplitude[0][3]);
				}
				if (u_inUse[1][0] > 0.0) {
					activeRipples++;
					vec2 relRippleCentre = vec2(u_originX[1][0], u_originY[1][0]) * 2.0 - 1.0;
					offset += computeDisplacement(relFragPos, relRippleCentre,
						u_frequency[1][0], u_time[1][0], u_speed[1][0], u_damping[1][0], u_amplitude[1][0]);
				}
				if (u_inUse[1][1] > 0.0) {
					activeRipples++;
					vec2 relRippleCentre = vec2(u_originX[1][1], u_originY[1][1]) * 2.0 - 1.0;
					offset += computeDisplacement(relFragPos, relRippleCentre,
						u_frequency[1][1], u_time[1][1], u_speed[1][1], u_damping[1][1], u_amplitude[1][1]);
				}
				if (u_inUse[1][2] > 0.0) {
					activeRipples++;
					vec2 relRippleCentre = vec2(u_originX[1][2], u_originY[1][2]) * 2.0 - 1.0;
					offset += computeDisplacement(relFragPos, relRippleCentre,
						u_frequency[1][2], u_time[1][2], u_speed[1][2], u_damping[1][2], u_amplitude[1][2]);
				}
				if (u_inUse[1][3] > 0.0) {
					activeRipples++;
					vec2 relRippleCentre = vec2(u_originX[1][3], u_originY[1][3]) * 2.0 - 1.0;
					offset += computeDisplacement(relFragPos, relRippleCentre,
						u_frequency[1][3], u_time[1][3], u_speed[1][3], u_damping[1][3], u_amplitude[1][3]);
				}
				if (u_inUse[2][0] > 0.0) {
					activeRipples++;
					vec2 relRippleCentre = vec2(u_originX[2][0], u_originY[2][0]) * 2.0 - 1.0;
					offset += computeDisplacement(relFragPos, relRippleCentre,
						u_frequency[2][0], u_time[2][0], u_speed[2][0], u_damping[2][0], u_amplitude[2][0]);
				}
				if (u_inUse[2][1] > 0.0) {
					activeRipples++;
					vec2 relRippleCentre = vec2(u_originX[2][1], u_originY[2][1]) * 2.0 - 1.0;
					offset += computeDisplacement(relFragPos, relRippleCentre,
						u_frequency[2][1], u_time[2][1], u_speed[2][1], u_damping[2][1], u_amplitude[2][1]);
				}
				if (u_inUse[2][2] > 0.0) {
					activeRipples++;
					vec2 relRippleCentre = vec2(u_originX[2][2], u_originY[2][2]) * 2.0 - 1.0;
					offset += computeDisplacement(relFragPos, relRippleCentre,
						u_frequency[2][2], u_time[2][2], u_speed[2][2], u_damping[2][2], u_amplitude[2][2]);
				}
				if (u_inUse[2][3] > 0.0) {
					activeRipples++;
					vec2 relRippleCentre = vec2(u_originX[2][3], u_originY[2][3]) * 2.0 - 1.0;
					offset += computeDisplacement(relFragPos, relRippleCentre,
						u_frequency[2][3], u_time[2][3], u_speed[2][3], u_damping[2][3], u_amplitude[2][3]);
				}
				if (u_inUse[3][0] > 0.0) {
					activeRipples++;
					vec2 relRippleCentre = vec2(u_originX[3][0], u_originY[3][0]) * 2.0 - 1.0;
					offset += computeDisplacement(relFragPos, relRippleCentre,
						u_frequency[3][0], u_time[3][0], u_speed[3][0], u_damping[3][0], u_amplitude[3][0]);
				}
				if (u_inUse[3][1] > 0.0) {
					activeRipples++;
					vec2 relRippleCentre = vec2(u_originX[3][1], u_originY[3][1]) * 2.0 - 1.0;
					offset += computeDisplacement(relFragPos, relRippleCentre,
						u_frequency[3][1], u_time[3][1], u_speed[3][1], u_damping[3][1], u_amplitude[3][1]);
				}
				if (u_inUse[3][2] > 0.0) {
					activeRipples++;
					vec2 relRippleCentre = vec2(u_originX[3][2], u_originY[3][2]) * 2.0 - 1.0;
					offset += computeDisplacement(relFragPos, relRippleCentre,
						u_frequency[3][2], u_time[3][2], u_speed[3][2], u_damping[3][2], u_amplitude[3][2]);
				}
				if (u_inUse[3][3] > 0.0) {
					activeRipples++;
					vec2 relRippleCentre = vec2(u_originX[3][3], u_originY[3][3]) * 2.0 - 1.0;
					offset += computeDisplacement(relFragPos, relRippleCentre,
						u_frequency[3][3], u_time[3][3], u_speed[3][3], u_damping[3][3], u_amplitude[3][3]);
				}
            }
            gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv.xy + offset);    
        }

		'
		#end
	)
	final MAX_RIPPLES = 16;

	var _defaultSpeed:Float;
	var _defaultFrequency:Float;
	var _defaultAmplitude:Float;
	var _defaultDamping:Float;

	var _startX:Float;
	var _startY:Float;

	var _decayTween:FlxTween;
	var _currentRipple:RippleProperties;

	var _active:Bool;

	var _ripples:Array<RippleProperties>;
	var _rippleIndexes:Array<Bool>; // whether specific index is in use
	var _rippleTweens:Array<NumTween>;

	/**
	 * Constructor
	 * @param speed the default speed of propagation of the ripples out from the center.
	 * @param frequency the default frequency of the ripples. The higher the number the tighter packed the ripples are.
	 * @param amplitude the default initial height of the ripples.
	 * @param damping the default higher the damping value the less effect the ripple has at a distance from the center
	 */
	public function new(speed:Float = 12.0, frequency:Float = 12.0, amplitude:Float = 0.03, damping:Float = 2.0)
	{
		super();
		_defaultSpeed = speed;
		_defaultFrequency = frequency;
		_defaultAmplitude = amplitude;
		_defaultDamping = damping;
		_decayTween = null;
		_active = false;

		// Initialize the uniform mapping for ripple uniforms
		_ripples = new Array<RippleProperties>();
		_rippleTweens = new Array<NumTween>();
		_rippleIndexes = new Array<Bool>();
		for (i in 0...MAX_RIPPLES)
		{
			_ripples[i] = {
				time: 0.0,
				speed: 0.0,
				frequency: 0.0,
				initialAmplitude: 0.0,
				amplitude: 0.0,
				damping: 0.0,
				startX: 0.0,
				startY: 0.0,
				uniformIdx: -1,
				inUse: false
			}
			_rippleIndexes[i] = false;
			_rippleTweens[i] = null;
		}
		// Initialize shader uniforms
		u_time.value = padToMat4([0.0]);
		u_inUse.value = padToMat4([0.0]);
		u_amplitude.value = padToMat4([0.0]);
		u_speed.value = padToMat4([0.0]);
		u_frequency.value = padToMat4([0.0]);
		u_damping.value = padToMat4([0.0]);
		u_originX.value = padToMat4([0.0]);
		u_originY.value = padToMat4([0.0]);
	}

	public static function gentleRipples():SineRippleShader
	{
		return new SineRippleShader(0.4, 28.7);
	}

	public static function denseRipples():SineRippleShader
	{
		return new SineRippleShader(0.7, 45.5, 0.1);
	}

	private function _allocUniformIdx():Int
	{
		for (i in 0...MAX_RIPPLES)
		{
			if (!_rippleIndexes[i])
			{
				_rippleIndexes[i] = true;
				return i;
			}
		}
		throw new ValueException('No available uniform sets');
	}

	private function _freeUniformIdx(idx:Int):Void
	{
		if (idx < 0 || idx >= MAX_RIPPLES)
		{
			throw new ValueException('Invalid idx ${idx} is not in range (0, ${MAX_RIPPLES - 1}).');
		}
		_rippleIndexes[idx] = false;
	}

	/**
	 * Start a ripple at point (x, y) with a given impact
	 * @param x x position relative to the position and size of the sprite
	 * @param y y position relative to the position and size of the sprite
	 * @param impact a proxy for the amount of force of the impact that starts the ripple
	 */
	public function start(x:Float, y:Float, impact:Float)
	{
		if (_decayTween != null)
		{
			return;
		}

		var uniformIdx = -1;
		try
		{
			uniformIdx = _allocUniformIdx();
		}
		catch (ValueException)
		{
			// No set of uniforms available at the moment
			return;
		}

		_startX = x;
		_startY = y;

		var newRipple = {
			time: 0.0,
			inUse: true,
			speed: _defaultSpeed,
			frequency: _defaultFrequency,
			initialAmplitude: _defaultAmplitude * impact,
			amplitude: _defaultAmplitude * impact,
			damping: _defaultDamping,
			startX: x,
			startY: y,
			uniformIdx: uniformIdx
		};

		_ripples[uniformIdx] = newRipple;

		if (!_active)
		{
			_active = true;
		}

		// FIXME figure out how to make duration (3rd param) depend on the strength of impact
		_rippleTweens[uniformIdx] = FlxTween.num(1.0, 0.0, 5.0, {onComplete: rippleComplete.bind(uniformIdx)}, decayRipple.bind(_ripples[uniformIdx]));
		_rippleTweens[uniformIdx].start();
	}

	/**
	 * Complete a specific ripple and release the uniform set.
	 * @param idx the index of the uniform set used by this ripple.
	 * @param tween the tween of this ripple
	 */
	function rippleComplete(idx:Int, tween:FlxTween):Void
	{
		_currentRipple = null;
		_decayTween = null;
		var stillActive = 0;
		for (i in 0...MAX_RIPPLES)
		{
			if (_ripples[i].inUse)
			{
				stillActive++;
			}
		}
		if (stillActive == 0)
		{
			_active = false;
		}
		_ripples[idx].inUse = false;
		_freeUniformIdx(idx);
	}

	/**
	 * Ripple decay function driven by the ripple tween.
	 * @param props the ripple properties for this ripple
	 * @param decay the decay value, supplied by the tween 
	 */
	function decayRipple(props:RippleProperties, decay:Float):Void
	{
		props.amplitude = props.initialAmplitude * decay;
		props.time += FlxG.elapsed;

		if (_active)
		{
			u_time.value[props.uniformIdx] = _ripples[props.uniformIdx].time;
			u_inUse.value[props.uniformIdx] = _ripples[props.uniformIdx].inUse ? 1.0 : 0.0;
			u_amplitude.value[props.uniformIdx] = _ripples[props.uniformIdx].amplitude;
			u_speed.value[props.uniformIdx] = _ripples[props.uniformIdx].speed;
			u_frequency.value[props.uniformIdx] = _ripples[props.uniformIdx].frequency;
			u_damping.value[props.uniformIdx] = _ripples[props.uniformIdx].damping;
			u_originX.value[props.uniformIdx] = _ripples[props.uniformIdx].startX;
			u_originY.value[props.uniformIdx] = _ripples[props.uniformIdx].startY;

			// Activate the shader as a whole
			u_active.value = [true];
		}
	}

	/**
	 * Set the default speed value. Larger values cause ripples to radiate outward faster.
	 * @param speed arbitrary speed value
	 */
	public function setSpeed(speed:Float):Void
	{
		_defaultSpeed = speed;
	}

	/**
	 * Set the default frequency value. The larger the value the more ripples per unit distance.
	 * @param frequency arbitrary frequency value
	 */
	public function setFrequency(frequency:Float):Void
	{
		_defaultFrequency = frequency;
	}

	/**
	 * Set the default amplitude. Higher values create a greater initial amplitude. 
	 * @param amplitude arbitrary amplitude value
	 */
	public function setAmplitude(amplitude:Float):Void
	{
		_defaultAmplitude = amplitude;
	}

	/**
	 * Set the default damping value. Higher values impede ripple effect more at a distance from the ripple
	 * center.
	 * @param damping arbitrary damping value
	 */
	public function setDamping(damping:Float):Void
	{
		_defaultDamping = damping;
	}

	/**
	 * Pad out a float array to fill a mat4. If the input array has fewer than 16 elements
	 * the returned array is padded with 0.0's up to 16. If the input array has more than
	 * 16 elements those greater than 16 are discarded.
	 * @param a the input array to be expanded
	 * @return Array<Float> a 16 element array padded with 0.0 elements if necessary
	 */
	private function padToMat4(a:Array<Float>):Array<Float>
	{
		var rv:Array<Float> = [];
		for (i in 0...16)
		{
			if (i > a.length)
			{
				rv.push(0.0);
			}
			else
			{
				rv.push(a[i]);
			}
		}
		return rv;
	}
}
