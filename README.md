# template-github-action

Template repo to kick start a composite Github action, providing the following features and configurations

1. [Sample composite action](action.yaml)
2. [Sample CI workflow](.github/workflows/ci.yml) to test the sample action
   - provided [assert.sh](assert.sh) to perform simple assertions in shell
3. [Repo setup script](setup_repo.sh) to configure the new repo
4. PR title linting to enforce that the PR titles follows [conventional commit standard](https://www.conventionalcommits.org/)
5. Configures dependabot to update any Github action dependencies
6. Dependabot automation workflow to automatically approve and squash merge dependabot PRs
7. Automated release with [release-please](https://github.com/googleapis/release-please-action)
8. Sample [CODEOWNERS](.github/CODEOWNERS) file

## Template usage

1. When creating a new repo
   1. Recommend to prefix the repo name with `action-`, e.g. `action-setup-playwright`
   2. Use the `Start with a template` option and select this repo as the template.
   3. Clone the new repo
   4. Make sure you have [Github CLI](https://github.com/cli/cli#installation) installed
   5. Open a bash terminal to the repo folder
   6. Run `./setup_repo.sh` to configure the repo settings. Note - this script self-deletes after successful run, commit
      the deletion as the script would be no longer required.
2. Search for word `CHANGE_ME` and modify the code as needed.
3. Replace this README file with documentation for the new action.
4. Implement the new action and release it with release-please
5. Ask in Slack channel `#team-step-enablement` or `#help-github` to grant dependabot access to this new repo
   1. so that consumers of your new action can receive automated upgrades when new version is released
   2. this setting is at the bottom of this page https://github.com/organizations/linz/settings/security_analysis
