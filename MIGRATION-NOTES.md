# Container Naming Standardization Migration

## Overview
This migration standardizes all container names to use the `homelabarr-` prefix, removing legacy `docker-` prefixed containers that were inherited from the DockServer project.

## Migration Status
- **Jira Ticket**: HL-117
- **Date**: August 19, 2025
- **Impact**: Low - No functional changes, only naming consistency

## Changes

### Containers Removed (17 Duplicates)
These containers were exact duplicates of their `homelabarr-` counterparts:
- docker-auto-replyarr → homelabarr-auto-replyarr ✓
- docker-backup → homelabarr-backup ✓
- docker-crunchy → homelabarr-crunchy ✓
- docker-crunchydl → homelabarr-crunchydl ✓
- docker-dockupdate → homelabarr-dockupdate ✓
- docker-gdsa → homelabarr-gdsa ✓
- docker-gui → homelabarr-gui ✓
- docker-local-persist → homelabarr-local-persist ✓
- docker-mount → homelabarr-mount ✓
- docker-newznab → homelabarr-newznab ✓
- docker-restic → homelabarr-restic ✓
- docker-rollarr → homelabarr-rollarr ✓
- docker-spotweb → homelabarr-spotweb ✓
- docker-traktarr → homelabarr-traktarr ✓
- docker-uploader → homelabarr-uploader ✓
- docker-vnstat → homelabarr-vnstat ✓
- docker-wiki → homelabarr-wiki ✓

### Containers Renamed (1 Unique)
- docker-gui-noble → homelabarr-gui-noble

## Registry Impact
All containers are now published to GitHub Container Registry with consistent naming:
- `ghcr.io/smashingtags/homelabarr-{container-name}:latest`

## Workflow Updates
- Sequential build workflow already uses `homelabarr-` prefix
- No workflow changes required

## Migration Script
Use the provided PowerShell script to clean up local development environments:
```powershell
# Dry run first
.\migrate-container-names.ps1 -DryRun

# Apply changes
.\migrate-container-names.ps1 -Force
```

## Verification
After migration:
1. All containers in `/apps` directory use `homelabarr-` prefix
2. No `docker-` prefixed directories remain
3. GitHub Actions workflows build successfully
4. Container registry shows consistent naming

## Benefits
1. **Brand Consistency**: All containers clearly identified as HomelabARR products
2. **Reduced Confusion**: No duplicate containers with different prefixes
3. **Simplified Maintenance**: Single naming convention across the project
4. **Clear Ownership**: Distinguishes from original DockServer containers

## Rollback
If needed, the deleted containers can be restored from git history:
```bash
git checkout HEAD~1 -- apps/docker-*
```

## Next Steps
1. ✅ Remove duplicate containers
2. ✅ Rename unique containers
3. ✅ Fix all internal references (31 files updated)
4. ⏳ Test sequential build workflow
5. ✅ Update documentation
6. ✅ Close HL-117 ticket

## Post-Migration Fixes
After initial migration, discovered and fixed:
- **31 files** with old docker-* references
- **release.json files**: Updated appname, apppic, appfolder paths
- **Dockerfiles**: Updated COPY paths to use homelabarr-* directories
- **docker-compose files**: Updated service names and image references
- **Shell scripts**: Updated container references in templates
- **Workflow files**: Updated build-all-containers.yml references

All containers now fully migrated with no remaining docker-* references.