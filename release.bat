7z a -tzip parasol.zip ^
    -i!parasol\shaders\* ^
    -x!parasol\shaders\PolyLineShader.hx ^
    -x!parasol\shaders\ColorChangeShader.hx ^
    -i!parasol\filters\* ^
    -i!parasol\math\* ^
    -i!parasol\macros\* ^
    -i!ATTRIBUTIONS.md -i!CHANGELOG.md -i!LICENSE -i!README.md -i!haxelib.json 