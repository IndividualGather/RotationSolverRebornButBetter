# Applies the fork branding to an upstream checkout (run from the upstream repo root).
# Uses exact text replacements instead of a patch so unrelated upstream edits nearby don't break it.
# If upstream moves a file, the text is searched for in all .cs files; it fails only when the text is gone.
$ErrorActionPreference = 'Stop'

function Replace-Once([string]$Path, [string]$Find, [string]$Replace) {
	# .NET resolves relative paths against the process directory, not the PowerShell location.
	$root = (Get-Location).Path
	$Path = Join-Path $root $Path
	if (-not (Test-Path $Path) -or -not ([IO.File]::ReadAllText($Path).Contains($Find))) {
		$found = @(Get-ChildItem $root -Recurse -Filter *.cs -File |
			Where-Object { $_.FullName -notmatch '[\/](bin|obj)[\/]' -and [IO.File]::ReadAllText($_.FullName).Contains($Find) })
		if ($found.Count -ne 1) { throw "Branding: expected exactly one file containing '$Find', found $($found.Count)" }
		Write-Host "Branding: '$Find' moved to $($found[0].FullName)"
		$Path = $found[0].FullName
	}
	$bytes = [IO.File]::ReadAllBytes($Path)
	$hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
	$text = [IO.File]::ReadAllText($Path)
	if (-not $text.Contains("`r`n")) { $Replace = $Replace.Replace("`r`n", "`n") }
	$index = $text.IndexOf($Find, [StringComparison]::Ordinal)
	$text = $text.Substring(0, $index) + $Replace + $text.Substring($index + $Find.Length)
	[IO.File]::WriteAllText($Path, $text, [Text.UTF8Encoding]::new($hasBom))
}

$nl = "`r`n"

# Teal accent colour (upstream default: red 0xB0201F). The UI library derives every colour from it.
# Settings are shared with the official plugin, so a saved upstream red default reads as teal too.
Replace-Once 'RotationSolver.Basic/Configuration/Configs.cs' `
	'public Vector4 UiAccentColor { get; set; } = new(0.690f, 0.125f, 0.122f, 1f);' `
	("public Vector4 UiAccentColor$nl" +
	"`t{$nl" +
	"`t`tget => Vector3.Distance(new Vector3(_forkAccentColor.X, _forkAccentColor.Y, _forkAccentColor.Z), new Vector3(0.690f, 0.125f, 0.122f)) < 0.005f$nl" +
	"`t`t`t? new Vector4(0.102f, 0.620f, 0.573f, 1f)$nl" +
	"`t`t`t: _forkAccentColor;$nl" +
	"`t`tset => _forkAccentColor = value;$nl" +
	"`t}$nl" +
	"`tprivate Vector4 _forkAccentColor = new(0.102f, 0.620f, 0.573f, 1f);")

# Window title.
Replace-Once 'RotationSolver/Data/UiString.cs' `
	'[Description("Rotation Solver Reborn Settings v")]' `
	'[Description("RotationSolverRebornButBetter Settings v")]'

# In-game logo (embedded resource).
Copy-Item (Join-Path $PSScriptRoot 'Logo.png') (Join-Path (Get-Location).Path 'Images/Logo.png') -Force

Write-Host 'Branding applied.'
