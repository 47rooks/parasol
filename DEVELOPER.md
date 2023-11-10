# Developer Readme

- [Developer Readme](#developer-readme)
  - [Setting up the development environment](#setting-up-the-development-environment)
  - [Building the tests](#building-the-tests)
  - [Build the haxelib](#build-the-haxelib)
  - [Updating the CHANGELOG.md](#updating-the-changelogmd)
  - [Creating documentation](#creating-documentation)
  - [Developing Tests](#developing-tests)

## Setting up the development environment

```
git clone github.com/parasol
cd parasol
haxelib newrepo
haxelib install libs.hxml
```

## Building the tests

Use VSCode with the vshaxe plugin.

To build the tests edit the `project.xml` and comment `<!-- <set name="examples"/> -->` and uncomment `<set name="tests"/>`.

or to build from the command line (powershell):

```
lime build hl
```

If you wish to build only selected tests build from the command line and before running the build set 
`UTEST_PATTERN <pattern to match test names>`. For example to run only the `ParasolShaderMacroTest` tests set

```
$env:UTEST_PATTERN = 'ParasolShaderMacroTest'
lime build hl
lime run hl -D UTEST_PRINT_TESTS
```

## Build the haxelib

Go to a command shell or Powershell
```
release.bat
```

## Updating the CHANGELOG.md

The CHANGELOG.md should only contain updates to the Haxelib package itself. All other updates to the repo are to be excluded.

## Creating documentation

Follow these steps
   + `git checkout gh-pages`
   + Create an XML file from the build containing all the type information for the targets of interest
```
haxelib run lime build hl -xml
```
   + Then run `dox` to generate the HTML files
```
haxelib run dox -i .\export\hl\types.xml -o export\docs --title "Parasol" -in "parasol" -in examples -D source-path https://github.com/47rooks/parasol/tree/main
```
   + Now commit the changed files and then push the branch to github. This branch does not merge to main.
```
git add .
git commit -m 'updated doc'
git push origin
```
   + Finally, switch to some other branch so you don't accidentally modify this branch further.

## Developing Tests

Unit tests are under the `tests` tree and the source is under `tests/src/unit`. Reference images and results are under `tests\reference`. Test data is under `tests\data`.

Tests that need to compare shader results against a reference image need to use the Capture utility. This involves the build macro in the `Project.xml` and it is enabled when the `name` variable is set to `tests`. Simply uncomment the line below and comment the `examples` line.
```
	<!-- Enable the next line to set the testing variable so that VSCode Intellisense and such
		 finds all the test artifacts and libs. Otherwise a simple -Dtesting flag added to the build
		 will build the test application. Removing it will build the game.
	-->
	<set name="tests"/>
	<!-- <set name="examples"/> -->
```

Using the Capture utility requires calling Capture.prepare() and Capture.wait() in the test and run the game loop between those two points. Refer to the `GrayscaleShaderTest.hx` `testGrayscaleShader()` for an example, but basically like this:
```
        Capture.prepare(Std.int(_gameHarness.width), Std.int(_gameHarness.height), true);
        _gameHarness.runGameLoop();
        Capture.wait();
```
You may then copy out the captured image and compare it to a reference. `Capture.image` contains the captured image.
```
        // To compare with reference
        var results = ImageComparator.equals(REFERENCE_DIR + "grayscaleref.png", Capture.image);
        Assert.equals(ComparatorResult.IDENTICAL, results);
```

When you need to create a new reference image substitute the following code for the reference comparison code above:

```
        ReferenceImageCreator.writeCaptureToPNG(new Rectangle(0, 0, 751, 493),
            "tests\\reference\\refimg.png");
```
This will write out the reference image to a PNG in the `export` tree under the bin directory when the process runs from. For example for Hashlink it will be under `export\hl\bin\tests\reference\`. Copy this file to the source tree as a reference object and the replace the `ReferenceImageCreator` call with the test validation code.

Note the GameHarness used creates a window size slightly larger than the requested 600x400. The actual size returned by the stage is 751x493.