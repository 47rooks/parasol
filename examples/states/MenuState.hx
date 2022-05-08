package examples.states;

import flixel.FlxG;
import flixel.addons.ui.FlxUIButton;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import examples.states.ThresholdShaderState;
import examples.states.BloomFilterState;
import examples.states.DemoState;

/**
 * MenuState provides a menu page for example shaders and filters.
 */
class MenuState extends DemoState
{
	static final LEFT_X = 10;
	static final TOP_Y = 100;
	static final LINE_Y = 60;
	static final TITLE_Y = 80;
	static final DESC_X = 220;
	static final TEXT_LENGTH = 450;

	public static final BASE_FONT_SIZE = 16;

	var _row:Int;

	override public function create()
	{
		super.create();

		// Set the font, rather globally
		FlxAssets.FONT_DEFAULT = "assets/fonts/OpenSans-Regular.ttf";

		// Add menu of demos
		_row = TOP_Y;
		var title = new FlxText(LEFT_X, _row, "Shader and Effect Demos", 48);
		add(title);

		_row += TITLE_Y;

		addMenuItem("Threshold Shader", () ->
		{
			FlxG.switchState(new ThresholdShaderState());
		}, "Threshold an image based on luma value of the colors");

		_row += LINE_Y;

		addMenuItem("Bloom filter", () ->
		{
			FlxG.switchState(new BloomFilterState());
		}, "A Gaussian bloom filter based on Learn OpenGL");

		// addMenuItem("Basic shaders", () ->
		// {
		// 	FlxG.switchState(new PolyLineShader());
		// }, "Basic color gradient.");

		// _row += LINE_Y;

		// addMenuItem("Basic Water", () ->
		// {
		// 	FlxG.switchState(new BasicWaterState());
		// }, "A basic sea-like water effect.");

		// _row += LINE_Y;

		_row += 2 * LINE_Y;

		add(new FlxText(LEFT_X, _row, "Hit <ESC> to exit the demo", BASE_FONT_SIZE));
	}

	/**
	 * Add an item consisting of one FlxUIButton and a FlxText description.
	 * 
	 * It will handle making them all consistent and centering the button in the description row.
	 * @param buttonLabel label for the button
	 * @param buttonCbk the callback to for the button click operation
	 * @param description the description of the demo that the button will launch
	 */
	private function addMenuItem(buttonLabel:String, buttonCbk:Void->Void, description:String)
	{
		var button = new FlxUIButton(LEFT_X, _row, buttonLabel, buttonCbk);
		var desc = new FlxText(DESC_X, _row, TEXT_LENGTH, description, BASE_FONT_SIZE);
		button.resize(200, 40);
		button.y = _row + (desc.height - button.height) / 2;
		button.setLabelFormat(14, FlxColor.BLACK, FlxTextAlign.CENTER);
		add(button);
		add(desc);
	}

	/**
	 * Override the DemoState update function to make the program exit if ESCAPE is hit.
	 * @param elapsed the elapsed time since the last update call.
	 */
	override public function update(elapsed:Float) {
		#if desktop
        if (FlxG.keys.justReleased.ESCAPE) {
            Sys.exit(0);
        }
		#end

        super.update(elapsed);
    }
}
