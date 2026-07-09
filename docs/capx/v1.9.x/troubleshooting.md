# Troubleshooting

## Clusterctl failed with GitHub rate limit error

By design Clusterctl fetches artifacts from repositories hosted on GitHub, this operation is subject to [GitHub API rate limits](https://docs.github.com/en/rest/overview/resources-in-the-rest-api#rate-limiting){target=_blank}.

While this is generally okay for the majority of users, there is still a chance that some users (especially developers or CI tools) hit this limit:

```
Error: failed to get repository client for the XXX with name YYY: error creating the GitHub repository client: failed to get GitHub latest version: failed to get the list of versions: rate limit for github api has been reached. Please wait one hour or get a personal API tokens a assign it to the GITHUB_TOKEN environment variable
```

As explained in the error message, you can increase your API rate limit by [creating a GitHub personal token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token){target=_blank} and setting a `GITHUB_TOKEN` environment variable using the token.
