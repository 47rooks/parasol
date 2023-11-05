package examples.states;

import examples.states.BloomFilterState;
import examples.states.RippleShaderState;
import examples.states.ShakeShaderState;
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
	
	static final COL_1_X = DESC_X + TEXT_LENGTH + 20;

	public static final BASE_FONT_SIZE = 16;
	static final TITLE_FONT_SIZE = 48;
	static final SUBTITLE_FONT_SIZE = 36;

	var _column_y_value:Array<Int>;

	override public function create()
	{
		super.create();
		_column_y_value = new Array<Int>();

		// Set the font, rather globally
		FlxAssets.FONT_DEFAULT = "assets/fonts/OpenSans-Regular.ttf";

		// Add menu of demos
		_column_y_value[0] = TOP_Y;
		var title = new FlxText(LEFT_X, _column_y_value[0], "Shader and Effect Demos", 48);
		add(title);

		_column_y_value[0] += TITLE_Y;

		// Fragment shader subtitle
		var fragment_subtitle = new FlxText(LEFT_X, _column_y_value[0], "Fragment Shaders", 36);
		add(fragment_subtitle);

		_column_y_value[0] += TITLE_Y;

		addMenuItem(0, "Threshold Shader", () ->
		{
			FlxG.switchState(new ThresholdShaderState());
		}, "Threshold an image based on luma value of the colors");

		_column_y_value[0] += LINE_Y;

		addMenuItem(0, "Grayscale Shader", () ->
		{
			FlxG.switchState(new GrayscaleShaderState());
		}, "Convert the image to a grayscale version");

		_column_y_value[0] += LINE_Y;

		addMenuItem(0, "Bloom filter", () ->
		{
			FlxG.switchState(new BloomFilterState());
		}, "A Gaussian bloom filter based on Learn OpenGL");

		_column_y_value[0] += LINE_Y;

		addMenuItem(0, "Ripple shader", () ->
		{
			FlxG.switchState(new RippleShaderState());
		}, "Sinusoidal ripple shader.");

		_column_y_value[0] += LINE_Y;

		addMenuItem(0, "Pixelation shader", () ->
		{
			FlxG.switchState(new PixelationShaderState());
		}, "Pixelation shader.");

		_column_y_value[0] += LINE_Y;

		addMenuItem(0, "Multi shader filter", () ->
		{
			FlxG.switchState(new MultiShaderState());
		}, "Multi shader example - grayscale and pixelation.");

		_column_y_value[0] += LINE_Y;

		addMenuItem(0, "Grayscale pixelation shader", () ->
		{
			FlxG.switchState(new GrayscalePixelationShaderState());
		}, "Grayscale pixelation shader - grayscale.fs loaded from file.");

		_column_y_value[0] += LINE_Y;

		_column_y_value[1] = TOP_Y + TITLE_Y;

		// Vertex shader subtitle
		var vertex_subtitle = new FlxText(COL_1_X, _column_y_value[1], "Vertex Shaders", 36);
		add(vertex_subtitle);

		_column_y_value[1] += TITLE_Y;

		addMenuItem(1, "Shake shader", () ->
		{
			FlxG.switchState(new ShakeShaderState());
		}, "Shake shader.");

		// _column_y_value[0] += LINE_Y;

		// addMenuItem("Basic shaders", () ->
		// {
		// 	FlxG.switchState(new PolyLineShader());
		// }, "Basic color gradient.");

		// _column_y_value[0] += LINE_Y;

		// addMenuItem("Basic Water", () ->
		// {
		// 	FlxG.switchState(new BasicWaterState());
		// }, "A basic sea-like water effect.");

		// _column_y_value[0] += LINE_Y;
		#if desktop
		_column_y_value[0] += 2 * LINE_Y;

		add(new FlxText(LEFT_X, _column_y_value[0], "Hit <ESC> to exit the demo", BASE_FONT_SIZE));
		#end
	}

	/**
	 * Add an item consisting of one FlxUIButton and a FlxText description.
	 * 
	 * It will handle making them all consistent and centering the button in the description row.
	 * @param columnNum which column to add the elemnt to
	 * @param buttonLabel label for the button
	 * @param buttonCbk the callback to for the button click operation
	 * @param description the description of the demo that the button will launch
	 */
	private function addMenuItem(columnNum:Int, buttonLabel:String, buttonCbk:Void->Void, description:String)
	{
		var buttonX = if (columnNum == 0) LEFT_X else COL_1_X;
		var descX = if (columnNum == 0) DESC_X else COL_1_X + DESC_X - LEFT_X;
		
		var button = new FlxUIButton(buttonX, _column_y_value[columnNum], buttonLabel, buttonCbk);
		var desc = new FlxText(descX, _column_y_value[columnNum], TEXT_LENGTH, description, BASE_FONT_SIZE);
		button.resize(200, 40);
		button.y = _column_y_value[columnNum] + (desc.height - button.height) / 2;
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
