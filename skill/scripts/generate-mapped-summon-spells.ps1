param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,
    [Parameter(Mandatory = $true)]
    [string]$NonGlobalTemplateLsx,
    [Parameter(Mandatory = $true)]
    [string]$NativeTemplateRoot,
    [Parameter(Mandatory = $true)]
    [string]$Divine,
    [Parameter(Mandatory = $true)]
    [string]$ModuleFolder,
    [string]$SpellPrefix = 'Target_SK_NG_',
    [string]$ContainerSpell = 'Target_SK_SummonMenu',
    [string]$SummonDonorSpell = 'Target_RangersCompanion',
    [string]$MarkerStatus = 'SK_CAPTURED_SUMMON',
    [string]$FallbackIcon = 'Spell_Conjuration_FindFamiliar',
    [string]$FallbackDisplayName = 'hskgenericname0000000000000000000001;1',
    [string]$FallbackDescription = 'hskgenericdesc0000000000000000000001;1',
    [string]$GuidSalt = 'SpiritKeeper:GlobalSummonRoot:'
)

$ErrorActionPreference = 'Stop'

$module = $ModuleFolder
$mapPath = Join-Path $ProjectRoot "PakRoot\Mods\$module\ScriptExtender\Lua\Data\SK_NonGlobalSummonRoots.lua"
$globalMapPath = Join-Path $ProjectRoot "PakRoot\Mods\$module\ScriptExtender\Lua\Data\SK_GlobalSummonRoots.lua"
$outputPath = Join-Path $ProjectRoot "PakRoot\Public\$module\Stats\Generated\Data\Spell_Target_SK_Mapped.txt"
$globalBuildDirectory = Join-Path $ProjectRoot 'Build\Generated'
$globalRootLsx = Join-Path $globalBuildDirectory 'SK_GlobalSummonRoots.lsx'
$globalPackageDirectory = Join-Path $ProjectRoot "PakRoot\Public\$module\RootTemplates"
$globalRootLsf = Join-Path $globalPackageDirectory 'SK_GlobalSummonRoots.lsf'
$pattern = "^\['(?<source>[0-9a-fA-F-]{36})'\]\s*=\s*`"(?<target>[0-9a-fA-F-]{36})`""
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$builder = [System.Text.StringBuilder]::new()
$rawMetadata = @{}
$globalTemplates = @{}
$globalTargetMap = @{}
$entries = @{}

function New-DeterministicGlobalRootGuid {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source
    )

    $md5 = [System.Security.Cryptography.MD5]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes(
            $GuidSalt + $Source.ToLowerInvariant())
        $hash = $md5.ComputeHash($bytes)
    } finally {
        $md5.Dispose()
    }
    $hash[6] = [byte](($hash[6] -band 0x0f) -bor 0x50)
    $hash[8] = [byte](($hash[8] -band 0x3f) -bor 0x80)
    $hex = -join ($hash | ForEach-Object { $_.ToString('x2') })
    return '{0}-{1}-{2}-{3}-{4}' -f `
        $hex.Substring(0, 8), `
        $hex.Substring(8, 4), `
        $hex.Substring(12, 4), `
        $hex.Substring(16, 4), `
        $hex.Substring(20, 12)
}

function Add-TemplateDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [bool]$CollectGlobals = $false
    )

    $document = [System.Xml.XmlDocument]::new()
    $document.PreserveWhitespace = $false
    $document.Load($Path)

    foreach ($node in $document.SelectNodes('//node[@id="GameObjects"]')) {
        $values = @{}
        foreach ($attribute in $node.SelectNodes('./attribute')) {
            $values[$attribute.GetAttribute('id')] = $attribute
        }
        if (-not $values.ContainsKey('MapKey')) {
            continue
        }
        if ($values.ContainsKey('Type') -and
            $values['Type'].GetAttribute('value') -ne 'character') {
            continue
        }

        $mapKey = $values['MapKey'].GetAttribute('value').ToLowerInvariant()
        $displayName = $null
        if ($values.ContainsKey('DisplayName')) {
            $handle = $values['DisplayName'].GetAttribute('handle')
            $version = $values['DisplayName'].GetAttribute('version')
            if ($handle) {
                if (-not $version) {
                    $version = '1'
                }
                $displayName = "$handle;$version"
            }
        }

        $templateName = $null
        if ($values.ContainsKey('TemplateName')) {
            $templateName = $values['TemplateName'].GetAttribute('value').ToLowerInvariant()
        }
        $parentTemplate = $null
        if ($values.ContainsKey('ParentTemplateId')) {
            $parentTemplate = $values['ParentTemplateId'].GetAttribute('value').ToLowerInvariant()
        }

        $rawMetadata[$mapKey] = @{
            DisplayName = $displayName
            TemplateName = $templateName
            ParentTemplate = $parentTemplate
        }

        if ($CollectGlobals) {
            $globalTemplates[$mapKey] = $node.CloneNode($true)
        }
    }
}

function Resolve-TemplateDisplayName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Template
    )

    $current = $Template.ToLowerInvariant()
    $seen = @{}
    for ($depth = 0; $depth -lt 32 -and $current; $depth++) {
        if ($seen.ContainsKey($current) -or -not $rawMetadata.ContainsKey($current)) {
            break
        }
        $seen[$current] = $true
        $metadata = $rawMetadata[$current]
        if ($metadata.DisplayName) {
            return $metadata.DisplayName
        }
        if ($metadata.TemplateName) {
            $current = $metadata.TemplateName
        } else {
            $current = $metadata.ParentTemplate
        }
    }

    return $FallbackDisplayName
}

function Add-SummonEntry {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,
        [Parameter(Mandatory = $true)]
        [string]$Target,
        [Parameter(Mandatory = $true)]
        [string]$Kind
    )

    $sourceKey = $Source.ToLowerInvariant()
    if ($entries.ContainsKey($sourceKey)) {
        return
    }
    $entries[$sourceKey] = @{
        Source = $sourceKey
        Target = $Target.ToLowerInvariant()
        Kind = $Kind
    }
}

function New-GlobalRootTemplates {
    $outputDocument = [System.Xml.XmlDocument]::new()
    $outputDocument.PreserveWhitespace = $false
    $outputDocument.LoadXml(
        '<?xml version="1.0" encoding="utf-8"?>' +
        '<save><version major="4" minor="0" revision="9" build="0" />' +
        '<region id="Templates"><node id="Templates"><children />' +
        '</node></region></save>')
    $outputChildren = $outputDocument.SelectSingleNode(
        '/save/region[@id="Templates"]/node[@id="Templates"]/children')
    $mapBuilder = [System.Text.StringBuilder]::new()
    [void]$mapBuilder.AppendLine('return {')

    foreach ($source in $globalTemplates.Keys | Sort-Object) {
        $sourceNode = $globalTemplates[$source]
        $templateNameNode = $sourceNode.SelectSingleNode(
            './attribute[@id="TemplateName"]')
        $existingParentNode = $sourceNode.SelectSingleNode(
            './attribute[@id="ParentTemplateId"]')
        $parentTemplate = if ($templateNameNode) {
            $templateNameNode.GetAttribute('value').ToLowerInvariant()
        } elseif ($existingParentNode) {
            $existingParentNode.GetAttribute('value').ToLowerInvariant()
        } else {
            $null
        }

        # A root without a base template cannot safely be converted into an
        # independently summonable object.
        if (-not $parentTemplate) {
            continue
        }

        $customRoot = New-DeterministicGlobalRootGuid -Source $source
        $clone = $sourceNode.CloneNode($true)
        $mapKeyNode = $clone.SelectSingleNode('./attribute[@id="MapKey"]')
        $mapKeyNode.SetAttribute('value', $customRoot)

        $nameNode = $clone.SelectSingleNode('./attribute[@id="Name"]')
        if ($nameNode) {
            $nameNode.SetAttribute('value', 'SK_Global_' + $nameNode.GetAttribute('value'))
        }

        $isGlobalNode = $clone.SelectSingleNode('./attribute[@id="IsGlobal"]')
        if ($isGlobalNode) {
            [void]$clone.RemoveChild($isGlobalNode)
        }

        $cloneTemplateNameNode = $clone.SelectSingleNode(
            './attribute[@id="TemplateName"]')
        if ($cloneTemplateNameNode) {
            [void]$clone.RemoveChild($cloneTemplateNameNode)
        }
        $cloneParentNode = $clone.SelectSingleNode(
            './attribute[@id="ParentTemplateId"]')
        if (-not $cloneParentNode) {
            $cloneParentNode = $clone.OwnerDocument.CreateElement('attribute')
            $cloneParentNode.SetAttribute('id', 'ParentTemplateId')
            $cloneParentNode.SetAttribute('type', 'FixedString')
            $childrenNode = $clone.SelectSingleNode('./children')
            if ($childrenNode) {
                [void]$clone.InsertBefore($cloneParentNode, $childrenNode)
            } else {
                [void]$clone.AppendChild($cloneParentNode)
            }
        }
        $cloneParentNode.SetAttribute('value', $parentTemplate)

        # The cloned template is a package RootTemplate, not a placed level
        # object.  It must not remain tied to the level where the corpse lived.
        $levelNameNode = $clone.SelectSingleNode('./attribute[@id="LevelName"]')
        if ($levelNameNode) {
            $levelNameNode.SetAttribute('value', '')
        }

        [void]$outputChildren.AppendChild(
            $outputDocument.ImportNode($clone, $true))
        $globalTargetMap[$source] = $customRoot
        $sourceMetadata = $rawMetadata[$source]
        $rawMetadata[$customRoot] = @{
            DisplayName = $sourceMetadata.DisplayName
            TemplateName = $null
            ParentTemplate = $parentTemplate
        }
        [void]$mapBuilder.AppendLine(
            "    ['$source'] = `"$customRoot`",")
    }
    [void]$mapBuilder.AppendLine('}')

    if (-not (Test-Path -LiteralPath $globalBuildDirectory)) {
        New-Item -ItemType Directory -Path $globalBuildDirectory | Out-Null
    }
    if (-not (Test-Path -LiteralPath $globalPackageDirectory)) {
        New-Item -ItemType Directory -Path $globalPackageDirectory | Out-Null
    }

    $settings = [System.Xml.XmlWriterSettings]::new()
    $settings.Encoding = $utf8NoBom
    $settings.Indent = $true
    $settings.IndentChars = "`t"
    $settings.NewLineChars = "`r`n"
    $settings.NewLineHandling = [System.Xml.NewLineHandling]::Replace
    $writer = [System.Xml.XmlWriter]::Create($globalRootLsx, $settings)
    try {
        $outputDocument.Save($writer)
    } finally {
        $writer.Dispose()
    }
    [System.IO.File]::WriteAllText(
        $globalMapPath, $mapBuilder.ToString(), $utf8NoBom)

    & $Divine -g bg3 -a convert-resource `
        -s $globalRootLsx `
        -d $globalRootLsf `
        -i lsx `
        -o lsf
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $globalRootLsf)) {
        throw "Failed to compile global summon RootTemplates to $globalRootLsf"
    }
}

Add-TemplateDocument -Path $NonGlobalTemplateLsx

$nativeRootFiles = @(
    Get-ChildItem -LiteralPath $NativeTemplateRoot -Recurse -Filter '*.lsx' |
        Where-Object {
            $_.FullName.Contains('\RootTemplates\') -or
            $_.FullName.Contains('\Globals\')
        } |
        Sort-Object FullName
)
if ($nativeRootFiles.Count -eq 0) {
    throw "No native RootTemplate/Global character LSX files found under $NativeTemplateRoot"
}
foreach ($file in $nativeRootFiles) {
    Add-TemplateDocument -Path $file.FullName `
        -CollectGlobals:$file.FullName.Contains('\Globals\')
}

New-GlobalRootTemplates

foreach ($line in [System.IO.File]::ReadLines($mapPath)) {
    $match = [regex]::Match($line, $pattern)
    if ($match.Success) {
        Add-SummonEntry `
            -Source $match.Groups['source'].Value `
            -Target $match.Groups['target'].Value `
            -Kind 'mapped-non-global'
    }
}
foreach ($source in $globalTargetMap.Keys) {
    Add-SummonEntry `
        -Source $source `
        -Target $globalTargetMap[$source] `
        -Kind 'mapped-global'
}

$mappedCount = 0
$globalCount = 0
foreach ($entry in $entries.Values | Sort-Object Source) {
    $source = $entry.Source
    $target = $entry.Target
    $sourceCompact = $source.Replace('-', '')
    $spell = $SpellPrefix + $sourceCompact
    $stackId = 'SKSummon_' + $sourceCompact
    $displayName = Resolve-TemplateDisplayName -Template $target

    [void]$builder.AppendLine("new entry `"$spell`"")
    [void]$builder.AppendLine('type "SpellData"')
    [void]$builder.AppendLine("using `"$SummonDonorSpell`"")
    [void]$builder.AppendLine("data `"SpellContainerID`" `"$ContainerSpell`"")
    [void]$builder.AppendLine('data "ContainerSpells" ""')
    [void]$builder.AppendLine('data "Cooldown" ""')
    [void]$builder.AppendLine("data `"SpellProperties`" `"GROUND:Summon($target,Permanent,,,'$stackId',UNSUMMON_ABLE,$MarkerStatus,SHADOWCURSE_SUMMON_CHECK)`"")
    [void]$builder.AppendLine("data `"TargetConditions`" `"CanStand('$target') and not Character() and not Item() and not Self()`"")
    # SpellData icons must be atlas-backed spell/action icons. Character
    # portrait keys are generated for character UI and render as question marks
    # in a linked spell container. Lua replaces this valid fallback with a
    # representative icon from the captured NPC's own spells when available.
    [void]$builder.AppendLine("data `"Icon`" `"$FallbackIcon`"")
    [void]$builder.AppendLine("data `"DisplayName`" `"$displayName`"")
    [void]$builder.AppendLine("data `"Description`" `"$FallbackDescription`"")
    [void]$builder.AppendLine('data "UseCosts" ""')
    [void]$builder.AppendLine('data "Requirements" ""')
    [void]$builder.AppendLine()

    if ($entry.Kind -eq 'mapped-global') {
        $globalCount++
    } else {
        $mappedCount++
    }
}

if ($entries.Count -eq 0) {
    throw "No summon entries were generated"
}

$outputDirectory = Split-Path -Parent $outputPath
if (-not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}
[System.IO.File]::WriteAllText($outputPath, $builder.ToString(), $utf8NoBom)
Write-Output "Generated $($entries.Count) static summon spells at $outputPath"
Write-Output "Mapped non-global entries: $mappedCount"
Write-Output "Mapped global entries: $globalCount"
Write-Output "Loaded metadata for $($rawMetadata.Count) character templates"
