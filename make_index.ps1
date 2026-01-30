<#
    make_index

    .DESCRIPTION
    spin through directory and make an index of icons by folder
#>

[string]$template = "template.html"
$template = Join-Path -Path $PSScriptRoot -ChildPath $template
if (-not (Test-Path $template)) {
    Write-Error "Template not found: ${template}"
    return 1;
}
[string]$workFile = "workFile.html"
$workFile = Join-Path -Path $PSScriptRoot -ChildPath $workFile
if (Test-Path $workFile) {
    Remove-Item $workFile -Force
}

[int32]$previewSize = 64;
[string]$LASTFOLDER = "--------"

$files = Get-ChildItem -Path $PSScriptRoot -Filter *.svg -Recurse | ForEach-Object { $_.FullName }
[bool]$first = $true
foreach ($file in $files) {
    [string]$name = Split-Path -Path $file -Leaf
    [string]$parentPath = Split-Path -Path (Get-Item $file).DirectoryName -Leaf

    if ($parentPath -ne $LASTFOLDER) {
        if (-not $first) {
            "</div></div>" >> $workFile
        }
        $LASTFOLDER = $parentPath;
        "<h2>${parentPath}</h2>" >> $workFile;
        "<div class='container'>" >> $workFile;
        "<div class='d-flex flex-wrap bg-light'>" >> $workFile
    }
    #"<div class='p-1 border w-20'><img src='$parentPath/$name' width=$previewSize /> <span class='zcaption'>$name</span></div>" >> $workFile
    [string]$caption = $name.Replace("-", "- ");
    "<div class='card p-3'><div class='card-title bg-primary-subtile text-black'><span class='zcaption'>$caption</span></div><div class='card-body'><img src='$parentPath/$name' width=$previewSize /></div></div>" >> $workFile
    
    $first = $false;
}
"</div></div>" >> $workFile

#
# Merge
[string]$indexFile = "index.html"
$indexFile = Join-Path -Path $PSScriptRoot -ChildPath $indexFile
if (Test-Path $indexFile) {
    Remove-Item $indexFile -Force
}

[string]$REPLACEHERE = "<!--HERE-->"
foreach ($line in Get-Content -Path $template) {
    if ($line.Trim().Contains($REPLACEHERE)) {
        "" >> $indexFile
        Get-Content -Path $workFile >> $indexFile;
        "" >> $indexFile
    }
    else {
        "$line" >> $indexFile;
    }
}

#
# Post-Process
(Get-Content -Path $indexFile) -replace "'", '"' | Set-Content -Path $indexFile

#
# Clean up
if (Test-Path $workFile) {
    Remove-Item $workFile -Force
}

Write-Output "Index: $indexFile"
return 0;