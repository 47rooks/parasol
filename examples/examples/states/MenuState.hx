package examples.states;

import examples.states.BloomFilterState;
import examples.states.RippleShaderState;
import examples.states.ThresholdShaderState;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxUIButton;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * MenuState provides a menu page for example shaders and filters.
 */
class MenuState extends FlxState
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

		addMenuItem("Grayscale Shader", () ->
		{
			FlxG.switchState(new GrayscaleShaderState());
		}, "Convert the image to a grayscale version");

		_row += LINE_Y;

		addMenuItem("Bloom filter", () ->
		{
			FlxG.switchState(new BloomFilterState());
		}, "A Gaussian bloom filter based on Learn OpenGL");

		_row += LINE_Y;

		addMenuItem("Ripple shader", () ->
		{
			FlxG.switchState(new RippleShaderState());
		}, "Sinusoidal ripple shader.");

		_row += LINE_Y;

		addMenuItem("Pixelation shader", () ->
		{
			FlxG.switchState(new PixelationShaderState());
		}, "Pixelation shader.");

		_row += LINE_Y;

		addMenuItem("Multi shader filter", () ->
		{
			FlxG.switchState(new MultiShaderState());
		}, "Multi shader example - grayscale and pixelation.");

		_row += LINE_Y;

		addMenuItem("Grayscale pixelation shader", () ->
		{
			FlxG.switchState(new GrayscalePixelationShaderState());
		}, "Grayscale pixelation shader - grayscale.fs loaded from file.");

		// _row += LINE_Y;

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
		#if desktop
		_row += 2 * LINE_Y;

		add(new FlxText(LEFT_X, _row, "Hit <ESC> to exit the demo", BASE_FONT_SIZE));
		#end
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

	#if desktop
	/**
	 * Override the DemoState update function to make the program exit if ESCAPE is hit.
	 * @param elapsed the elapsed time since the last update call.
	 */
	override public function update(elapsed:Float) {
        if (FlxG.keys.justReleased.ESCAPE) {
            Sys.exit(0);
        }

        super.update(elapsed);
    }
	#end

}
