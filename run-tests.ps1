# Runs every tests/test_*.pl file, each in its own SWI-Prolog process
# (each file loads the solution with a different knowledge base).
#
#   .\run-tests.ps1           run all test files
#   .\run-tests.ps1 kb2       run only the files whose name contains "kb2"

param([string]$Only = "")

$swipl = (Get-Command swipl -ErrorAction SilentlyContinue).Source
if (-not $swipl) {
    $default = "C:\Program Files\swipl\bin\swipl.exe"
    if (Test-Path $default) { $swipl = $default }
    else {
        Write-Host "SWI-Prolog (swipl) not found. Install it first." -ForegroundColor Red
        exit 1
    }
}

$files = Get-ChildItem (Join-Path $PSScriptRoot "tests") -Filter "test_*.pl" | Sort-Object Name
if ($Only) { $files = $files | Where-Object { $_.BaseName -like "*$Only*" } }
if (-not $files) {
    Write-Host "No test files match '$Only'." -ForegroundColor Red
    exit 1
}

$failed = @()
foreach ($file in $files) {
    Write-Host ""
    Write-Host "== $($file.Name)" -ForegroundColor Cyan
    & $swipl -q -g run_tests -t halt $file.FullName
    if ($LASTEXITCODE -ne 0) { $failed += $file.Name }
}

Write-Host ""
if ($failed.Count -eq 0) {
    Write-Host "All $($files.Count) test file(s) passed." -ForegroundColor Green
    exit 0
}
Write-Host "Failed: $($failed -join ', ')" -ForegroundColor Red
exit 1
