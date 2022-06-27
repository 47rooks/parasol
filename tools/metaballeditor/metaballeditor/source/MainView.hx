package;

import EquationSystem.ErrorData;
import haxe.ui.components.TextField;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;

/**
 * MainView provides the UI for enter equations and other parameters. It also provides support for
 * saving and loading metaball definitions and images.
 */
@:build(haxe.ui.ComponentBuilder.build("assets/main-view.xml"))
class MainView extends VBox
{
	var _generateButtonCbk:(Array<Array<String>>, xyTransform:Array<String>, x:Int, y:Int) -> Null<Array<ErrorData>>;

	public function new(generateButtonCbk:(falloffFunctions:Array<Array<String>>, xyTransform:Array<String>, x:Int, y:Int) -> Null<Array<ErrorData>>)
	{
		super();
		_generateButtonCbk = generateButtonCbk;
	}

	@:bind(generateButton, MouseEvent.CLICK)
	private function onGenerate(e:MouseEvent)
	{
		generateButton.disabled = true;

		// Get the falloff functions
		var falloffFunctions = new Array<Array<String>>();
		for (i in 0...falloffEquations.numComponents)
		{
			var r = falloffEquations.getComponentAt(i);
			var eqnStr = new Array<String>();
			for (j in 0...r.numComponents)
			{
				var c = r.getComponentAt(j);
				var tf = c.getComponentAt(0);
				eqnStr.push(tf.text);
			}
			if (eqnStr[0] != null && eqnStr[0].length > 0 && eqnStr[1] != null && eqnStr[1].length > 0)
			{
				// Only keep equations that are entered
				falloffFunctions.push(eqnStr);
			}
		}

		// Get the xy transform if one is specified
		var t = xyTransform.getComponentAt(0);
		var txfrmEqn = new Array<String>();
		for (j in 0...t.numComponents)
		{
			var c = t.getComponentAt(j);
			var tf = c.getComponentAt(0);
			txfrmEqn.push(tf.text);
		}
		if (txfrmEqn[0] == null || txfrmEqn[2] == null)
		{
			// Do not retain a null or partly null entry
			txfrmEqn = new Array<String>();
		}

		// Process the equations
		var errors = _generateButtonCbk(falloffFunctions, txfrmEqn, Std.parseInt(xpixels.text), Std.parseInt(ypixels.text));

		generateButton.disabled = false;
	}

	@:bind(exitButton, MouseEvent.CLICK)
	private function onExitButton(e:MouseEvent)
	{
		Sys.exit(0);
	}
}
