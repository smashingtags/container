# Fix all remaining docker-* references in homelabarr-* containers
# This script updates release.json files, Dockerfiles, and other references

param(
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"
$appsPath = "c:\Users\micha\OneDrive\Desktop\homelabarr-containers-master\apps"

Write-Host "`n=== Fixing Container References ===" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "[DRY RUN MODE] No changes will be made" -ForegroundColor Yellow
}

# Map of old names to new names
$containerMap = @{
    "docker-auto-replyarr" = "homelabarr-auto-replyarr"
    "docker-backup" = "homelabarr-backup"
    "docker-crunchy" = "homelabarr-crunchy"
    "docker-crunchydl" = "homelabarr-crunchydl"
    "docker-dockupdate" = "homelabarr-dockupdate"
    "docker-gdsa" = "homelabarr-gdsa"
    "docker-gui" = "homelabarr-gui"
    "docker-gui-noble" = "homelabarr-gui-noble"
    "docker-local-persist" = "homelabarr-local-persist"
    "docker-mount" = "homelabarr-mount"
    "docker-newznab" = "homelabarr-newznab"
    "docker-restic" = "homelabarr-restic"
    "docker-rollarr" = "homelabarr-rollarr"
    "docker-spotweb" = "homelabarr-spotweb"
    "docker-traktarr" = "homelabarr-traktarr"
    "docker-uploader" = "homelabarr-uploader"
    "docker-vnstat" = "homelabarr-vnstat"
    "docker-wiki" = "homelabarr-wiki"
}

$totalFixed = 0

# Process each homelabarr-* container
$homelabarrDirs = Get-ChildItem -Path $appsPath -Directory | Where-Object { $_.Name -like 'homelabarr-*' }

foreach ($dir in $homelabarrDirs) {
    Write-Host "`nProcessing: $($dir.Name)" -ForegroundColor Green
    $filesFixed = 0
    
    # Get all files in the container directory
    $files = Get-ChildItem -Path $dir.FullName -Recurse -File
    
    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if (-not $content) { continue }
        
        $originalContent = $content
        $updated = $false
        
        # Replace all docker-* references with homelabarr-*
        foreach ($oldName in $containerMap.Keys) {
            if ($content -match [regex]::Escape($oldName)) {
                $newName = $containerMap[$oldName]
                $content = $content -replace [regex]::Escape($oldName), $newName
                $updated = $true
            }
        }
        
        # Also update common patterns
        $content = $content -replace "Docker image\s+for docker-", "Docker image for homelabarr-"
        $content = $content -replace "Upgrading docker-", "Upgrading homelabarr-"
        $content = $content -replace "./apps/docker-", "./apps/homelabarr-"
        $content = $content -replace "./images/docker-", "./images/homelabarr-"
        $content = $content -replace "COPY ./apps/docker-", "COPY ./apps/homelabarr-"
        $content = $content -replace "COPY --from=builder /app/docker-", "COPY --from=builder /app/homelabarr-"
        
        if ($content -ne $originalContent) {
            $relativePath = $file.FullName.Replace($dir.FullName + "\", "")
            if ($DryRun) {
                Write-Host "  [DRY RUN] Would update: $relativePath" -ForegroundColor Yellow
            } else {
                Set-Content -Path $file.FullName -Value $content -NoNewline
                Write-Host "  [UPDATED] $relativePath" -ForegroundColor Cyan
            }
            $filesFixed++
        }
    }
    
    if ($filesFixed -gt 0) {
        Write-Host "  Fixed $filesFixed file(s) in $($dir.Name)" -ForegroundColor Green
        $totalFixed += $filesFixed
    } else {
        Write-Host "  No changes needed" -ForegroundColor Gray
    }
}

# Fix templates directory
Write-Host "`n=== Checking Templates ===" -ForegroundColor Green
$templatesPath = "c:\Users\micha\OneDrive\Desktop\homelabarr-containers-master\.templates"
if (Test-Path $templatesPath) {
    $templateFiles = Get-ChildItem -Path $templatesPath -Recurse -File
    foreach ($file in $templateFiles) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if (-not $content) { continue }
        
        $originalContent = $content
        foreach ($oldName in $containerMap.Keys) {
            if ($content -match [regex]::Escape($oldName)) {
                $newName = $containerMap[$oldName]
                $content = $content -replace [regex]::Escape($oldName), $newName
            }
        }
        
        if ($content -ne $originalContent) {
            if ($DryRun) {
                Write-Host "  [DRY RUN] Would update: $($file.Name)" -ForegroundColor Yellow
            } else {
                Set-Content -Path $file.FullName -Value $content -NoNewline
                Write-Host "  [UPDATED] $($file.Name)" -ForegroundColor Cyan
            }
            $totalFixed++
        }
    }
}

# Fix workflow files
Write-Host "`n=== Checking Workflows ===" -ForegroundColor Green
$workflowPath = "c:\Users\micha\OneDrive\Desktop\homelabarr-containers-master\.github\workflows"
$workflows = Get-ChildItem -Path $workflowPath -Filter "*.yml"

foreach ($workflow in $workflows) {
    $content = Get-Content $workflow.FullName -Raw
    $originalContent = $content
    
    foreach ($oldName in $containerMap.Keys) {
        if ($content -match [regex]::Escape($oldName)) {
            $newName = $containerMap[$oldName]
            $content = $content -replace [regex]::Escape($oldName), $newName
        }
    }
    
    if ($content -ne $originalContent) {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would update: $($workflow.Name)" -ForegroundColor Yellow
        } else {
            Set-Content -Path $workflow.FullName -Value $content -NoNewline
            Write-Host "  [UPDATED] $($workflow.Name)" -ForegroundColor Cyan
        }
        $totalFixed++
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Total files fixed: $totalFixed"

if ($DryRun) {
    Write-Host "`nRun without -DryRun to apply changes" -ForegroundColor Yellow
}