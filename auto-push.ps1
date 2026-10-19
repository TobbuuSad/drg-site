# DRG auto-push: watches fresh players.json / players.js in "Downloads"
# and automatically pushes changes to GitHub.

$ErrorActionPreference = "Continue"

function Resolve-Git {
	if (Get-Command git -ErrorAction SilentlyContinue) { return (Get-Command git).Source }
	foreach ($dir in @("C:\Program Files\Git")) {
		$found = Get-ChildItem $dir -Recurse -Filter git.exe -ErrorAction SilentlyContinue | Select-Object -First 1
		if ($found) { return $found.FullName }
	}
	return $null
}

$git = Resolve-Git
if (-not $git) {
	Write-Host "[ERROR] Git not found!" -ForegroundColor Red
	Read-Host "Press Enter to exit"
	exit 1
}

Set-Location $PSScriptRoot
Write-Host "=== DRG auto-push started ===" -ForegroundColor Cyan
Write-Host "Watching 'Downloads'. Changes will be pushed to GitHub automatically."
Write-Host "Keep this window open. Close it to stop."
Write-Host ""

while ($true) {
	Start-Sleep -Seconds 3
	try {
		robocopy "$env:USERPROFILE\Downloads" . players.json players.js /XO /NJH /NJS /NP /NFL /NDL | Out-Null
		if ($LASTEXITCODE -gt 7) { $LASTEXITCODE = 0 }
	} catch {}

	& $git add players.json players.js index.html 2>$null | Out-Null
	$hasChanges = $false
	& $git diff --cached --quiet
	if ($LASTEXITCODE -eq 1) { $hasChanges = $true }

	if ($hasChanges) {
		Write-Host "[$([DateTime]::Now.ToString('HH:mm:ss'))] Changes found - pushing to GitHub..." -ForegroundColor Yellow
		& $git commit -m "Auto-update roster" 2>&1 | Out-Null
		$push = & $git push 2>&1
		if ($LASTEXITCODE -eq 0) {
			Write-Host "[$([DateTime]::Now.ToString('HH:mm:ss'))] [OK] Pushed! Site refreshes in 1-2 min, mod picks it up in ~1 min." -ForegroundColor Green
		} else {
			Write-Host "[$([DateTime]::Now.ToString('HH:mm:ss'))] [ERROR] Push failed: $push" -ForegroundColor Red
			# undo the commit so the next loop tries again
			& $git reset --soft HEAD~1 2>&1 | Out-Null
		}
	}
}
