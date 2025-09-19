#!/usr/bin/env bash

# GitHub Actions Migration Helper Script
# This script helps complete the migration from CircleCI to GitHub Actions

set -e

echo "🚀 GitHub Actions Migration Helper"
echo "=================================="

# Check if we're in the right directory
if [[ ! -f "Makefile" ]] || [[ ! -f "docker-compose.yml" ]]; then
    echo "❌ Error: This doesn't appear to be the funcake-solr repository root"
    echo "Please run this script from the repository root directory"
    exit 1
fi

echo "✅ Repository structure validated"

# Check if GitHub Actions workflows exist
if [[ -d ".github/workflows" ]]; then
    echo "✅ GitHub Actions workflows directory exists"
    echo "   Found workflows:"
    ls -1 .github/workflows/*.yml | sed 's/^/   - /'
else
    echo "❌ GitHub Actions workflows not found"
    exit 1
fi

# Check if scripts exist and are executable
if [[ -f ".github/scripts/build.sh" ]] && [[ -x ".github/scripts/build.sh" ]]; then
    echo "✅ Build script exists and is executable"
else
    echo "❌ Build script is missing or not executable"
    exit 1
fi

if [[ -f ".github/scripts/deploy.sh" ]] && [[ -x ".github/scripts/deploy.sh" ]]; then
    echo "✅ Deploy script exists and is executable"
else
    echo "❌ Deploy script is missing or not executable"
    exit 1
fi

echo ""
echo "🔍 Next Steps:"
echo "1. Commit and push the GitHub Actions configuration"
echo "2. Test the workflows by creating a pull request"
echo "3. Test deployment by creating and pushing a tag"
echo "4. Configure the required secrets in GitHub repository settings:"
echo "   - SOLR_USER"
echo "   - SOLR_PASSWORD"
echo ""

read -p "Do you want to remove the CircleCI configuration now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Removing CircleCI configuration..."
    if [[ -d ".circleci" ]]; then
        rm -rf .circleci
        echo "✅ CircleCI configuration removed"
    else
        echo "⚠️  CircleCI configuration not found"
    fi
else
    echo "⏭️  Keeping CircleCI configuration for now"
    echo "   You can remove it later with: rm -rf .circleci"
fi

echo ""
echo "✨ Migration setup complete!"
echo ""
echo "📚 For more information, see .github/MIGRATION.md"
