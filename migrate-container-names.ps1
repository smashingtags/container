# HomelabARR Container Naming Migration Script
# This script removes redundant docker-* containers and renames remaining ones to homelabarr-*

param(
    [switch]$DryRun = $false,
    [switch]$Force = $false
)

$ErrorActionPreference = "Stop"
$appsPath = "c:\Users\micha\OneDrive\Desktop\homelabarr-containers-master\apps"

Write-Host "`n=== HomelabARR Container Naming Migration ===" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "[DRY RUN MODE] No changes will be made" -ForegroundColor Yellow
}

# Containers to remove (duplicates)
$duplicatesToRemove = @(
    "docker-auto-replyarr",
    "docker-backup",
    "docker-crunchy",
    "docker-crunchydl",
    "docker-dockupdate",
    "docker-gdsa",
    "docker-gui",
    "docker-local-persist",
    "docker-mount",
    "docker-newznab",
    "docker-restic",
    "docker-rollarr",
    "docker-spotweb",
    "docker-traktarr",
    "docker-uploader",
    "docker-vnstat",
    "docker-wiki"
)

# Containers to rename
$containersToRename = @(
    @{Old = "docker-gui-noble"; New = "homelabarr-gui-noble"}
)

# Step 1: Remove duplicate containers
Write-Host "`n=== Step 1: Removing Duplicate Containers ===" -ForegroundColor Green
foreach ($container in $duplicatesToRemove) {
    $containerPath = Join-Path $appsPath $container
    if (Test-Path $containerPath) {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would remove: $container" -ForegroundColor Yellow
        } else {
            if ($Force -or (Read-Host "Remove $container? (y/n)") -eq 'y') {
                Remove-Item -Path $containerPath -Recurse -Force
                Write-Host "  [REMOVED] $container" -ForegroundColor Red
            } else {
                Write-Host "  [SKIPPED] $container" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "  [NOT FOUND] $container" -ForegroundColor DarkGray
    }
}

# Step 2: Rename remaining containers
Write-Host "`n=== Step 2: Renaming Unique Containers ===" -ForegroundColor Green
foreach ($rename in $containersToRename) {
    $oldPath = Join-Path $appsPath $rename.Old
    $newPath = Join-Path $appsPath $rename.New
    
    if (Test-Path $oldPath) {
        if (Test-Path $newPath) {
            Write-Host "  [WARNING] Target already exists: $($rename.New)" -ForegroundColor Yellow
        } else {
            if ($DryRun) {
                Write-Host "  [DRY RUN] Would rename: $($rename.Old) -> $($rename.New)" -ForegroundColor Yellow
            } else {
                if ($Force -or (Read-Host "Rename $($rename.Old) to $($rename.New)? (y/n)") -eq 'y') {
                    Rename-Item -Path $oldPath -NewName $rename.New
                    Write-Host "  [RENAMED] $($rename.Old) -> $($rename.New)" -ForegroundColor Green
                    
                    # Update internal references in renamed container
                    $dockerfilePath = Join-Path $newPath "Dockerfile"
                    if (Test-Path $dockerfilePath) {
                        $content = Get-Content $dockerfilePath -Raw
                        $content = $content -replace "docker-gui-noble", "homelabarr-gui-noble"
                        $content = $content -replace "DockServer", "HomelabARR"
                        Set-Content -Path $dockerfilePath -Value $content
                        Write-Host "    [UPDATED] Dockerfile references" -ForegroundColor Cyan
                    }
                } else {
                    Write-Host "  [SKIPPED] $($rename.Old)" -ForegroundColor Gray
                }
            }
        }
    } else {
        Write-Host "  [NOT FOUND] $($rename.Old)" -ForegroundColor DarkGray
    }
}

# Step 3: Update any workflow references
Write-Host "`n=== Step 3: Checking Workflow References ===" -ForegroundColor Green
$workflowPath = "c:\Users\micha\OneDrive\Desktop\homelabarr-containers-master\.github\workflows"
$workflows = Get-ChildItem -Path $workflowPath -Filter "*.yml"

foreach ($workflow in $workflows) {
    $content = Get-Content $workflow.FullName -Raw
    $hasDockerReferences = $content -match "docker-(gui-noble)"
    
    if ($hasDockerReferences) {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would update: $($workflow.Name)" -ForegroundColor Yellow
        } else {
            $content = $content -replace "docker-gui-noble", "homelabarr-gui-noble"
            Set-Content -Path $workflow.FullName -Value $content
            Write-Host "  [UPDATED] $($workflow.Name)" -ForegroundColor Green
        }
    }
}

Write-Host "`n=== Migration Complete ===" -ForegroundColor Cyan
Write-Host "Summary:"
Write-Host "  - Removed: $($duplicatesToRemove.Count) duplicate containers"
Write-Host "  - Renamed: $($containersToRename.Count) unique containers"
Write-Host "  - All containers now use 'homelabarr-' prefix"

if ($DryRun) {
    Write-Host "`nRun without -DryRun to apply changes" -ForegroundColor Yellow
}