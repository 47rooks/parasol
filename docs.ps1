haxelib run dox -i .\export\hl\types.xml -o docs --title "Parasol" -in "parasol" -in examples -D source-path https://github.com/47rooks/parasol/tree/main
<#
 Search for all the URLs in the examples section and replace main/examples with main/examples/examples
 to workaround bad behaviour in dox.
#>
Get-ChildItem -path .\docs\examples -Recurse |
ForEach-Object {
    $searchStr = "main/examples"
    $replaceStr = "main/examples/examples"
    if ($_ -is [System.io.FileInfo]) {
        $content = Get-Content $_.FullName
        if ($content -match $searchStr) {
            $modifiedContent = $content -replace $searchStr, $replaceStr
            Set-Content $_.FullName $modifiedContent
        }
    }
}