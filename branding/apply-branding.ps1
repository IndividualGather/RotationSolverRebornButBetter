# Applies the fork branding to an upstream checkout (run from the upstream repo root).
# Uses exact text replacements instead of a patch so unrelated upstream edits nearby don't break it;
# fails only when a replaced line itself is gone.
$ErrorActionPreference = 'Stop'

function Replace-Once([string]$Path, [string]$Find, [string]$Replace) {
	# .NET resolves relative paths against the process directory, not the PowerShell location.
	$Path = Join-Path (Get-Location).Path $Path
	$bytes = [IO.File]::ReadAllBytes($Path)
	$hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
	$text = [IO.File]::ReadAllText($Path)
	if (-not $text.Contains("`r`n")) { $Replace = $Replace.Replace("`r`n", "`n") }
	$index = $text.IndexOf($Find, [StringComparison]::Ordinal)
	if ($index -lt 0) { throw "Branding: text not found in ${Path}: $Find" }
	$text = $text.Substring(0, $index) + $Replace + $text.Substring($index + $Find.Length)
	[IO.File]::WriteAllText($Path, $text, [Text.UTF8Encoding]::new($hasBom))
}

$nl = "`r`n"

# Teal default accent colour (upstream: red 0xB0201F). Every UI colour is derived from it.
Replace-Once 'RotationSolver/UI/Material/M3.cs' `
	'public static readonly Vector4 DefaultSeed = M3ColorMath.FromRgb(0xB0201F);' `
	("public static readonly Vector4 DefaultSeed = M3ColorMath.FromRgb(0x1A9E92);$nl" +
	"`tprivate static readonly Vector4 UpstreamDefaultSeed = M3ColorMath.FromRgb(0xB0201F);")

# Settings are shared with the official plugin, so a config holding upstream's red default shows teal too.
Replace-Once 'RotationSolver/UI/Material/M3.cs' `
	'var seed = Service.Config.UiAccentColor;' `
	("var seed = Service.Config.UiAccentColor;$nl" +
	"`t`t`tif (Vector3.Distance(new Vector3(seed.X, seed.Y, seed.Z), new Vector3(UpstreamDefaultSeed.X, UpstreamDefaultSeed.Y, UpstreamDefaultSeed.Z)) < 0.005f)$nl" +
	"`t`t`t{$nl" +
	"`t`t`t`tseed = DefaultSeed;$nl" +
	"`t`t`t}")

# Window title.
Replace-Once 'RotationSolver/Data/UiString.cs' `
	'[Description("Rotation Solver Reborn Settings v")]' `
	'[Description("RotationSolverRebornButBetter Settings v")]'

# In-game logo (embedded resource).
Copy-Item (Join-Path $PSScriptRoot 'Logo.png') 'Images/Logo.png' -Force

Write-Host 'Branding applied.'
