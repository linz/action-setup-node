#! /usr/bin/env bash
# This script sets up a GitHub repository with recommended settings.

REPO_NAME_WITH_OWNER=$(gh repo view --json nameWithOwner -q '.nameWithOwner')

read -p "Initialising repo setting for $REPO_NAME_WITH_OWNER. Continue (y/N)? " choice
case "$choice" in 
  y|Y ) echo "Proceeding...";;
  * ) echo "Abort" && exit 1;;
esac

echo "Configure basic repo settings..."
gh api \
  --silent \
  --method PATCH \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "/repos/$REPO_NAME_WITH_OWNER" \
  --input - <<< '{
  "has_wiki": false,
  "allow_squash_merge": true,
  "allow_merge_commit": false,
  "allow_rebase_merge": false,
  "allow_auto_merge": true,
  "delete_branch_on_merge": true,
  "use_squash_pr_title_as_default": true,
  "squash_merge_commit_title": "PR_TITLE",
  "squash_merge_commit_message": "PR_BODY"
}'

echo "Enable Dependabot alerts..."
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "/repos/$REPO_NAME_WITH_OWNER/vulnerability-alerts"

echo "Enable Dependabot security updates..."
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "/repos/$REPO_NAME_WITH_OWNER/automated-security-fixes"

echo "Allow action in this repo to be accessible from repositories in the 'linz' organization..."
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "/repos/$REPO_NAME_WITH_OWNER/actions/permissions/access" \
  --input - <<< '{
   "access_level": "organization"
}'

if gh ruleset list | grep --quiet "Default branch"; then
  echo "Default branch ruleset already exists."
else
  echo "Setup ruleset to protect default branch..."
  # note - "integration_id": 15368 is 'Github Actions'
  gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "/repos/$REPO_NAME_WITH_OWNER/rulesets" \
    --input - <<< '{
  "name": "Default branch",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": [
        "~DEFAULT_BRANCH"
      ],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "deletion"
    },
    {
      "type": "non_fast_forward"
    },
    {
      "type": "pull_request",
      "parameters": {
        "allowed_merge_methods": ["squash"],
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": true,
        "require_last_push_approval": true,
        "required_approving_review_count": 1,
        "required_review_thread_resolution": false
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": false,
        "required_status_checks": [
          {
            "context": "test",
            "integration_id": 15368
          },
          {
            "context": "pr-lint",
            "integration_id": 15368
          }
        ]
      }
    }
  ]
}'
fi

echo "✅ Repo settings applied."

me=$(basename "$0")
rm "$me"
echo "✅ Deleted $me, you can commit this change to the repo as the script is no longer needed."