package;

import EquationSystem.ErrorData;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

/**
 * The Metaball Editor state is used for processing equation input and driving the display of the metaball.
 */
class MEState extends FlxState
{
	final UI_WIDTH:Int = FlxG.width;

	var _demoCamera:FlxCamera;
	var _equations:EquationSystem;
	var _formulaeUpdated:Bool = false;
	var _mbWidth:Int;
	var _mbHeight:Int;
	var _demoPaneCenter:FlxPoint;
	var _editorSprite:Metaball;

	override public function new()
	{
		super();
		UI_WIDTH = 900;
	}

	override public function create():Void
	{
		super.create();

		// Add UI to default camera
		FlxG.camera.width = UI_WIDTH;
		FlxG.camera.bgColor = 0xFFFFFFFF;

		// Create the camera to display the metaball
		_demoCamera = new FlxCamera(UI_WIDTH, 0, FlxG.width - UI_WIDTH, FlxG.height);
		FlxG.cameras.add(_demoCamera, false);
		_demoCamera.bgColor = FlxColor.BLACK;
		_demoCamera.bgColor.alphaFloat = 0.0;

		// Add UI view
		add(new MainView(generateCallback));

		// Setup the metaball display area
		_demoPaneCenter = getDisplayPaneCenter();
	}

	/**
	 * This callback receives the equations from the UI and processes them so that a metaball can be created.
	 * @param falloffFunctions the functions defining the falloff
	 * @param xyTransform if supplied a function which transform x and y into an intermediate variable usually
	 * used as a domain variable in the falloff equations.
	 * @param mbWidth the width in pixels of the final metaball image
	 * @param mbHeight the height in pixels of the final metaball image
	 * @return Null<Array<ErrorData>> if there are errors in the input equations error data is returned, otherwise null.
	 */
	private function generateCallback(falloffFunctions:Array<Array<String>>, xyTransform:Array<String>, mbWidth:Int, mbHeight:Int):Null<Array<ErrorData>>
	{
		try
		{
			_equations = new EquationSystem(falloffFunctions, xyTransform);
			_mbWidth = mbWidth;
			_mbHeight = mbHeight;

			_formulaeUpdated = true;
		}
		catch (e:ESException)
		{
			trace('e=${e.errorData}'); // FIXME once error reporting is added remove this
			return e.errorData;
		}
		return null;
	}

	/**
	 * Get the center of the display panel
	 * @return FlxPoint containing the coordinates of the center.
	 */
	private function getDisplayPaneCenter():FlxPoint
	{
		return new FlxPoint((FlxG.width - UI_WIDTH) / 2, FlxG.height / 2);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justReleased.ESCAPE)
		{
			Sys.exit(0);
		}

		if (_formulaeUpdated)
		{
			// Remove old sprite if there is one
			if (_editorSprite != null)
			{
				remove(_editorSprite);
			}

			// Create new metaball bitmap
			var mb = new MetaballBuilder(_equations, _mbWidth, _mbHeight);
			var bmd = mb.generate();
			_editorSprite = new Metaball(_demoPaneCenter.x, _demoPaneCenter.y, bmd, _demoCamera);
			add(_editorSprite);

			// clear the formulaeUpdated flag so we only do this once per new set of equations
			_formulaeUpdated = false;
		}
	}
}
