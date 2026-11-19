# Copies the solution into submission/ after a few last checks.
# The Google Form takes this one file: submission/chess_58-3825.pl
#
#   .\make-submission.ps1

$solution = Join-Path $PSScriptRoot "chess_58-3825.pl"
$outDir   = Join-Path $PSScriptRoot "submission"
$problems = @()

$text = Get-Content -Raw $solution
$lines = Get-Content $solution

if ($lines[0] -ne ":- include('KB1.pl').") {
    $problems += "The first line must be :- include('KB1.pl')."
}
if ($text -match 'T\?\?') {
    $problems += "The team comment still has a tutorial written as T??."
}
if ($lines | Select-String -Pattern '^(grid|knight_at|bishop_at)\s*\(') {
    $problems += "The file contains KB facts; they must stay in KB1.pl / KB2.pl."
}
$code = $lines | Where-Object { $_ -notmatch '^\s*%' }
if ($code | Select-String -Pattern '\b(assert[az]?|retract(all)?)\s*\(') {
    $problems += "The file uses assert or retract."
}

$swipl = (Get-Command swipl -ErrorAction SilentlyContinue).Source
if (-not $swipl) { $swipl = "C:\Program Files\swipl\bin\swipl.exe" }
$loadOutput = & $swipl -q -g halt $solution 2>&1 | Out-String
if ($loadOutput.Trim() -ne "") {
    $problems += "Loading the file prints warnings or errors:`n$loadOutput"
}

Write-Host "Running all tests (about half a minute)..."
& (Join-Path $PSScriptRoot "run-tests.ps1") *> $null
if ($LASTEXITCODE -ne 0) {
    $problems += "Some tests fail. Run .\run-tests.ps1 to see which."
}

if ($problems.Count -gt 0) {
    Write-Host "Not ready to submit:" -ForegroundColor Red
    $problems | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    exit 1
}

New-Item -ItemType Directory -Force $outDir | Out-Null
Copy-Item $solution $outDir -Force
Write-Host "Ready: submission\chess_58-3825.pl (all checks and tests passed)" -ForegroundColor Green
