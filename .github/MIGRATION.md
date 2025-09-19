# GitHub Actions Migration

This repository has been migrated from CircleCI to GitHub Actions.

## Workflows

### Test Workflow (`.github/workflows/test.yml`)
- **Trigger**: Runs on every push to `main` branch and on pull requests
- **Purpose**: Runs the test suite to ensure code quality
- **Steps**:
  1. Checkout code
  2. Set up Ruby environment with bundler cache
  3. Set up Docker Buildx
  4. Build and start services using `make up`
  5. Load test data using `make load-data`
  6. Run tests using `make test`
  7. Clean up with `make down`

### Deploy Workflow (`.github/workflows/deploy.yml`)
- **Trigger**: Runs only when tags are pushed (releases)
- **Purpose**: Deploys Solr configuration to SolrCloud and creates GitHub release assets
- **Jobs**:
  1. **Test Job**: Same as test workflow to ensure quality before deployment
  2. **Deploy Job**: 
     - Builds configuration asset (zip file)
     - Deploys to SolrCloud (uploads config, creates collections and aliases)
     - Uploads asset to GitHub release

## Required Secrets

The following secrets need to be configured in the GitHub repository settings:

- `SOLR_USER`: Username for SolrCloud authentication
- `SOLR_PASSWORD`: Password for SolrCloud authentication
- `GITHUB_TOKEN`: GitHub token for release asset uploads (automatically provided by GitHub Actions)

## Scripts

### `.github/scripts/build.sh`
Creates the Solr configuration zip file, excluding development and CI-related files.

### `.github/scripts/deploy.sh`
Handles the deployment process:
- Uploads Solr configuration to SolrCloud
- Creates Solr collections and aliases
- Uploads zip file to GitHub release

## Migration Notes

### Changes from CircleCI:
1. **Environment**: Changed from CircleCI's `machine` executor to GitHub Actions `ubuntu-latest`
2. **Caching**: Switched from CircleCI cache to Ruby's built-in bundler cache
3. **Docker**: Using GitHub Actions Docker setup instead of CircleCI's built-in Docker
4. **Variables**: 
   - `CIRCLE_TAG` → `GITHUB_REF` (with tag name extraction)
   - `/home/circleci/` paths → `/home/runner/` paths
5. **Scripts**: Updated file paths to exclude `.github/*` instead of `.circle*`

### Preserved Functionality:
- Same test suite execution
- Same build process (zip creation)
- Same deployment logic to SolrCloud
- Same GitHub release asset upload
- Same exclusion patterns for zip file creation

## Testing the Migration

1. **Test workflow**: Create a PR to trigger the test workflow
2. **Deploy workflow**: Create and push a tag to trigger the deploy workflow

```bash
# Test the build locally
make up
make load-data
make test
make down

# Test the zip creation
./.github/scripts/build.sh
```
