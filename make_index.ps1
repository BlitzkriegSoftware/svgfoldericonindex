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

function stringToHash() {
    param(
        [string]$text
    )
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    $sha256 = [System.Security.Cryptography.HashAlgorithm]::Create("SHA256")
    $hashBytes = $sha256.ComputeHash($bytes)
    # Convert the byte array to a hex string
    $hashString = ($hashBytes | ForEach-Object { $_.ToString("x2") }) -join ""
    return $hashString
}

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

#
# Table of Contents
"<h3 id='top'>Table of Contents</h3><p>" >> $workFile

$toc = @{}
$dirs = Get-ChildItem -Directory -Path $IconRootPath -Recurse | ForEach-Object { $_.FullName }
foreach ($dir in $dirs) {
    [string]$parentPath = Split-Path -Path (Get-Item $dir) -Leaf
    $parentPath = $parentPath.trim();
    $hash = stringToHash -text $parentPath
    $toc.Add($parentPath, $hash);
    "<a href='#${hash}' class='link-offset-2 link-offset-3-hover link-underline link-underline-opacity-0 link-underline-opacity-75-hover'>$parentPath</a> <i class='bi bi-dot fs-7'></i> " >> $workFile
}
"</p>" >> $workFile

# Change this to set size of Image
[int32]$previewSize = 64;

# Supported by Chrome as 2026-02-02
$graphics = [string[]]@("*.svg", "*.png", "*.jpg", "*jpeg", "*.jfif", "*.gif", "*.webp", "*.avif", "*.bmp", "*.ico", "*.tiff");

"<h2>Icons</h2>" >> $workFile
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
        $hash = $toc[$parentPath]
        "<h3 id='${hash}'>${parentPath}    <a href='#top' style='font-size=4pt;'>^top</a></h3>" >> $workFile;
        "<div class='container m-2'>" >> $workFile;
        "<div class='d-flex flex-wrap bg-light'>" >> $workFile
    }
    [string]$caption = $name.Replace("-", "- ");
    [string]$copyPath = "${parentPath}/${name}"
    $copyPath = "!!" + $copyPath + "!!";
    "<div class='card p-2 m-2'><div class='card-title bg-primary-subtle text-black p-1 m-1'><span style='font-size: 8pt'>$caption</span> <i onclick='copyTextToClipboard($copyPath)' class='bi bi-copy fs-7'></i></div><div class='card-body'><img src='$parentPath/$name' width=$previewSize /></div></div>" >> $workFile
    
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