7z a -tzip parasol.zip ^
    -i!parasol\shaders\* ^
    -x!parasol\shaders\PolyLineShader.hx ^
    -x!parasol\shaders\ColorChangeShader.hx ^
    -x!parasol\shaders\glsl ^
    -i!parasol\filters\* ^
    -i!parasol\math\* ^
    -i!ATTRIBUTIONS.md -i!CHANGELOG.md -i!LICENSE -i!README.md -i!haxelib.json 