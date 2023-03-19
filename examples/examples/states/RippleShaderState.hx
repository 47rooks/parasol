package examples.states;

import examples.states.ImagesState;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.FlxUICheckBox;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import parasol.shaders.SineRippleShader;

class RippleShaderState extends ImagesState
{
	var _shader:FlxShader;
	var _mousePos:FlxPoint;

	var _controls:Controls;

	// Ripple effect tunables
	var _frequency:Float = 12.0;
	var _speed:Float = 4.0;
	var _amplitude:Float = 0.03;
	var _damping:Float = 2.0;

	var _mouseHoldTime:Float = 0.0;

	override public function create()
	{
		super.create();
		
		final LINE_X = 50;

		// Create a second camera for the controls so they will not be affected by filters.
		_controlsCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		_controlsCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(_controlsCamera, false);
		add(_controlsCamera);

		// Create controls
		var enableC = new FlxUICheckBox(Controls.LINE_X, 50, null, null, "Enable Effect", 200, null, toggleShader);
		enableC.getLabel().size = 15;

		var frequencySlider = new FlxSlider(this, "_frequency", Controls.LINE_X, 100.0, 0.0, 64.0, 300, 15, 3, FlxColor.WHITE, FlxColor.WHITE);
		frequencySlider.setTexts("Frequency", true, "0.0", "64.0", 15);

		var speedSlider = new FlxSlider(this, "_speed", Controls.LINE_X, 170.0, 0.0, 4.0, 300, 15, 3, FlxColor.WHITE, FlxColor.WHITE);
		speedSlider.setTexts("Speed", true, "0", "4.0", 15);

		var amplitudeSlider = new FlxSlider(this, "_amplitude", Controls.LINE_X, 230.0, 0.0, 1.0, 300, 15, 3, FlxColor.WHITE, FlxColor.WHITE);
		amplitudeSlider.setTexts("Amplitude", true, "0.0", "1.0", 15);

		var dampingSlider = new FlxSlider(this, "_damping", Controls.LINE_X, 290.0, 0.0, 100.0, 300, 15, 3, FlxColor.WHITE, FlxColor.WHITE);
		dampingSlider.setTexts("Damping", true, "0.0", "100.0", 15);

		_controls = new Controls(20, 100, 400, 600, [
			// Add a checkbox to turn the shader on and off
			enableC,
			// Add a slider for the ripple frequency
			frequencySlider,
			// Add a slider for the ripple speed
			speedSlider,
			// Add a slider for the ripple amplitude
			amplitudeSlider,
			// Add a slider for the ripple damping
			dampingSlider,
			// Add a pulldown to choose the image
			getImageChooser(Controls.LINE_X, 370)
		], _controlsCamera);

		// Add controls to state
		add(_controls._controls);

		// _sprite = new FlxSprite();
		// _sprite.loadGraphic('assets/images/fractal city 960x540.png');

		// // _sprite.loadGraphic('assets/images/Ground_01.png');
		// add(_sprite);

		_shader = new SineRippleShader();

		_mousePos = FlxG.mouse.getPosition();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justReleased.S)
		{
			if (_sprite.shader != null)
			{
				_sprite.shader = null;
			}
			else
			{
				_sprite.shader = _shader;
			}
		}

		if (FlxG.mouse.justPressed)
		{
			_mouseHoldTime = 0.0;
		}
		if (FlxG.mouse.pressed)
		{
			_mouseHoldTime += elapsed;
		}
		if (FlxG.mouse.justReleased)
		{
			if (FlxG.mouse.overlaps(_sprite) && !_controls.mouseOverlaps() && _sprite.shader != null)
			{
				_mousePos = FlxG.mouse.getPosition();
				_mousePos.x = (_mousePos.x - _sprite.x) / _sprite.width;
				_mousePos.y = (_mousePos.y - _sprite.y) / _sprite.height;

				cast(_shader, SineRippleShader).start(_mousePos.x, _mousePos.y, _mouseHoldTime * 10.0);
			}
			_mouseHoldTime = 0.0;
		}

		if (_sprite.shader != null)
		{
			// These fields should only be set when the slider changes but the slider has no callback
			cast(_shader, SineRippleShader).setAmplitude(_amplitude);
			cast(_shader, SineRippleShader).setFrequency(_frequency);
			cast(_shader, SineRippleShader).setSpeed(_speed);
			cast(_shader, SineRippleShader).setDamping(_damping);
		}
	}

	/**
	 * Toggle the shader on and off, callback for enable checkbox.
	 */
	private function toggleShader()
	{
		if (_sprite.shader != null)
		{
			_sprite.shader = null;
		}
		else
		{
			_sprite.shader = _shader;
		}
	}
}
