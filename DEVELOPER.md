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

or to build from the command line:

```
lime build hl
```

## Build the haxelib

Go to a command shell or Powershell
```
release.bat
```

## Updating the CHANGELOG.md

The CHANGELOG.md should only contain updates to the Haxelib package itself. All other updates to the repo are to be excluded.