- [What does it do?](#what-does-it-do)
  - [Supported image formats](#supported-image-formats)
  - [Usage](#usage)
    - [Example](#example)
  - [Customize Template](#customize-template)
  - [Credits](#credits)

# What does it do?

Given a shallow folder tree of icons, makes an index of them

## Supported image formats

```powershell
# Supported by Chrome as 2026-02-02
$graphics = [string[]]@("*.svg", "*.png", "*.jpg", "*jpeg", "*.jfif", "*.gif", "*.webp", "*.avif", "*.bmp", "*.ico", "*.tiff");
```

## Usage

```text
make_index.ps1 [[-IconRootPath] <string>] [<CommonParameters>]
```

- `-IconRootPath` will default to `$PSScriptRoot`

### Example

```powershell
.\make_index.ps1 .\Azure_Public_Service_Icons\Icons\
```

Output will be in

```text
Index: .\Azure_Public_Service_Icons\Icons\index.html
```

## Customize Template

You can Customize the `Template.html`

## Credits

Great compactness and functionality deserves credit

- [Bootstrap 5](https://getbootstrap.com/)
- [Google Fonts](https://fonts.google.com/)
- [jsdelivr CDN](https://www.jsdelivr.com/)
- [Microsoft Powershell Core 7](https://learn.microsoft.com/en-us/shows/it-ops-talk/how-to-install-powershell-7)
