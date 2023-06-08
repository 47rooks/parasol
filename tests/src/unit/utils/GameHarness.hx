package unit.utils;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.events.Event;
import sys.thread.Deque;

class GameHarness extends FlxGame {
    /**
     * _runLoop permits the game loop to run unobstructed in the case where there is no
     * test control thread, by preventing blocking attempts to get the run permission,
     * until the test thread sets it to true by calling runGameLoop().
     */
    var _runLoop:Bool;

    /* Block the game thread until we need to run the loop */
    var _runLock:Deque<Int>;

    /* Synchronize the test driver thread so we have positive confirmation that
     * the game loop has finished its current cycle.
     */
    var _clientLock:Deque<Int>;
    
	/**
	 * Constructor
	 * @param gameW the width of the game
	 * @param gameH the height of the game
	 */
	public function new(gameW:Int = 1920, gameH:Int = 1080)
    {
        #if (flixel < "5")
        super(gameW, gameH, null, 1, 60, 60, true); 4.xx with initialZoom=1
        #else
        super(gameW, gameH, null, 60, 60, true);
        #end

        // do not run the game loop until instructed
        _runLoop = false;

        // Turn the mouse off so it is not captured in images.
        // If it is captured reference comparisons can break.
        FlxG.mouse.visible = false;

        // Initialize the synchronization queues
        _runLock = new Deque();
        _clientLock = new Deque();
    }

    /**
     * Override this function to control the starting of the game loop.
     * The game loop will only run if the test driver thread has called runGameLoop().
     * @param _ the openfl Event object. Ignored here and passed to super.onEnterFrame().
     */
    override function onEnterFrame(_:Event) {
        if (_runLoop) {
            // Block until test thread has granted permission to run game loop
            _runLock.pop(true);

            // Run actual game loop
            super.onEnterFrame(_);

            // Disable run so next iteration does not block
            _runLoop = false;
            // Notify test thread that this loop has completed
            _clientLock.push(1);
        }
    }

    /**
     * Run one iteration of the game loop and wait for it to complete.
     */
    public function runGameLoop() {
        // Release game thread to run a cycle
        _runLock.push(1);
        _runLoop = true;
        
        // Wait for game loop to ping back
        _clientLock.pop(true);
    }
}