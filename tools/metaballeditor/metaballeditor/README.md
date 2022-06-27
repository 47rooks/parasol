# Building from Scratch

   + Clone the parasol repo
   + Run the following commands
```
cd tools/metaballeditor/metaballeditor
haxelib newrepo
haxelib git haxeui-core https://github.com/haxeui/haxeui-core.git
haxelib git haxeui-flixel https://github.com/haxeui/haxeui-flixel.git
haxelib install openfl
haxelib run openfl setup
haxelib install flixel
haxelib run lime setup flixel
```

Now if you have already cloned the repo the next step is already done. If not this is how a new
```
haxelib run haxeui-core create flixel
```

# To Do

   * add button to each row to clear the equation
   * set domain limits to min -inf and max +inf, including placeholder
   * add ability to save definition to a user specified file
   * add ability to load a save definition
   * add error display
   * expand piecewise equation restrictions to work directly with x,y so intermediate equation is not required
   * add PNG save
   * add demo pane to show how the metaballs look while moving
   * add color gradient support
   * corner markers for the test sprite
   * do something about a progress bar
   * floats must have preceding 0 in formula evaluation - .9 fails where 0.8 is ok
   * refactor the removal of '=' from equations to the UI layer out of EquationSystem processing
   * refactor error and exception information so they are together
   * Consider implementing a proper package hierarchy to clean up the chaos