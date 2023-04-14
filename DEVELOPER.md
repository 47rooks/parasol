# Developer Readme

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