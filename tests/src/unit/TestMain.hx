package unit;

import unit.utils.ImageComparatorTest;
import openfl.events.Event;
import openfl.display.Sprite;
import unit.parasol.math.KernelsTest;
import unit.parasol.math.DistributionsTest;
import unit.parasol.shaders.GrayscaleShaderTest;
import unit.parasol.shaders.LineShaderTest;
import utest.Runner;
import utest.ui.Report;

/** 
 * NoExitReport is a workaround to prevent the Sys.exit() that is called
 * when the reporter finishes.
 * 
 * This workaround comes from https://github.com/haxe-utest/utest/issues/105
 */
class NoExitReport extends utest.ui.text.PrintReport {
	override function complete(result:utest.ui.common.PackageResult) {
	  this.result = result;
	  if (handler != null) handler(this);
	}
}

/**
 * TestMain runs utest tests on OpenFL event listeners. Normally utest is run
 * as a simple main() function. The approach used here is used where you need to
 * run another OpenFL application under the control of utest tests, for example
 * testing HaxeFlixel games.
 */
class TestMain extends Sprite
{
	var _runner:Runner;

	/**
	 * Constructor. The primary thing this does is install an ADDED_TO_STAGE listener
	 * so that the tests can be setup.
	 */
	public function new()
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, prepareTests);
	}

	/**
	 * An event handler function for the ADDED_TO_STAGE event which initializes the
	 * the test Runner with all the tests it should run.
	 * 
	 * @param _ the event payload. Ignored.
	 */
	private function prepareTests(_): Void
	{
		_runner = new Runner();
		_runner.addCase(new DistributionsTest());
		_runner.addCase(new KernelsTest());
		_runner.addCase(new LineShaderTest());
		_runner.addCase(new GrayscaleShaderTest(stage));
		_runner.addCase(new ImageComparatorTest());

		// Remove setup event handler and add one to run the tests
		// on the game loop.
		removeEventListener(Event.ADDED_TO_STAGE, prepareTests);
		addEventListener(Event.ENTER_FRAME, runTests);
	}

	/**
	 * An event handler function for the ENTER_FRAME event to run the
	 * tests in the event loop.
	 * 
	 * @param _ the event payload. Ignored.
	 */
	private function runTests(_): Void
	{
		// Currently all tests are launched in a separate thread
		// in the first loop but implementation could be expanded
		// to allow multiple loops and execution of different tests
		// in different cycles, but the threading in particular presents issues.

		// Note that the test runner runs in a separate thread
		// after this point. If the event listener is left in place
		// a new thread will be created on each ENTER_FRAME event each running
		// these tests. Remove it now.
		removeEventListener(Event.ENTER_FRAME, runTests);
		sys.thread.Thread.create(() -> {
			// Note that the runner will terminate the runtime when the
			// report is printed. If this is not desired use the
			// NoExitReport reporter instead.
			Report.create(_runner);
			// new NoExitReport(_runner);
			_runner.run();
		});
	}
}
