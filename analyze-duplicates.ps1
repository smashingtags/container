$dockerDirs = Get-ChildItem -Path "c:\Users\micha\OneDrive\Desktop\homelabarr-containers-master\apps" -Directory | Where-Object { $_.Name -like 'docker-*' }

Write-Host "`n=== Container Naming Analysis ===`n"
Write-Host "Found $($dockerDirs.Count) docker-* containers"

$duplicates = @()
$unique = @()

foreach ($dir in $dockerDirs) {
    $dockerName = $dir.Name
    $homelabarrName = $dockerName -replace '^docker-', 'homelabarr-'
    $homelabarrPath = Join-Path $dir.Parent.FullName $homelabarrName
    
    if (Test-Path $homelabarrPath) {
        $duplicates += $dockerName
        Write-Host "[DUPLICATE] $dockerName -> $homelabarrName" -ForegroundColor Yellow
    } else {
        $unique += $dockerName
        Write-Host "[UNIQUE]    $dockerName" -ForegroundColor Green
    }
}

Write-Host "`n=== Summary ==="
Write-Host "Duplicates: $($duplicates.Count) containers"
Write-Host "Unique: $($unique.Count) containers"
Write-Host "`nDuplicate containers that can be removed:"
$duplicates | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }

if ($unique.Count -gt 0) {
    Write-Host "`nUnique containers that need renaming:"
    $unique | ForEach-Object { Write-Host "  - $_" -ForegroundColor Cyan }
}