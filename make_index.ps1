<#
    make_index

    .DESCRIPTION
    spin through directory and make an index of icons by folder
#>

[CmdletBinding()]
param (
    # Where are the icons
    [Parameter()]
    [string]
    $IconRootPath = $PSScriptRoot
)

if ([String]::IsNullOrWhiteSpace($IconRootPath)) {
    $IconRootPath = $PSScriptRoot
}

[string]$template = "template.html"
$template = Join-Path -Path $PSScriptRoot -ChildPath $template
if (-not (Test-Path $template)) {
    Write-Error "Template not found: ${template}"
    return 1;
}
[string]$workFile = "workFile.html"
$workFile = Join-Path -Path $IconRootPath -ChildPath $workFile
if (Test-Path $workFile) {
    Remove-Item $workFile -Force
}

# Change this to set size of Image
[int32]$previewSize = 64;

# Supported by Chrome as 2026-02-02
$graphics = [string[]]@("*.svg", "*.png", "*.jpg", "*jpeg", "*.jfif", "*.gif", "*.webp", "*.avif", "*.bmp", "*.ico", "*.tiff");

$files = Get-ChildItem -Path $IconRootPath -Include $graphics -Recurse | ForEach-Object { $_.FullName }
[bool]$first = $true
[string]$LASTFOLDER = "--------"
foreach ($file in $files) {
    [string]$name = Split-Path -Path $file -Leaf
    $name = $name.Trim();
    [string]$parentPath = Split-Path -Path (Get-Item $file).DirectoryName -Leaf
    $parentPath = $parentPath.trim();

    if ($parentPath -ne $LASTFOLDER) {
        if (-not $first) {
            "</div></div>" >> $workFile
        }
        $LASTFOLDER = $parentPath;
        "<h2>${parentPath}</h2>" >> $workFile;
        "<div class='container m-3'>" >> $workFile;
        "<div class='d-flex flex-wrap bg-light'>" >> $workFile
    }
    [string]$caption = $name.Replace("-", "- ");
    [string]$copyPath = "${parentPath}/${name}"
    $copyPath = "!!" + $copyPath + "!!";
    "<div class='card p-3 m-1'><div class='card-title bg-primary-subtile text-black'><span class='zcaption'>$caption</span><i onclick='copyTextToClipboard($copyPath)' class='bi bi-copy fs-5'></i></div><div class='card-body'><img src='$parentPath/$name' width=$previewSize /></div></div>" >> $workFile
    
    $first = $false;
}
"</div></div>" >> $workFile

#
# Post-Process
(Get-Content -Path $workFile) -replace "'", '"' | Set-Content -Path $workFile
(Get-Content -Path $workFile) -replace "!!", "'" | Set-Content -Path $workFile

#
# Merge
[string]$indexFile = "index.html"
$indexFile = Join-Path -Path $IconRootPath -ChildPath $indexFile
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
# Clean up
if (Test-Path $workFile) {
    Remove-Item $workFile -Force
}

Write-Output "Index: $indexFile"
return 0;