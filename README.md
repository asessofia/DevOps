#  Redis Storage
The Redis cache store is used by the Harmony/Engage application for level 2 caching of the website data. Builds and deployments are controlled by Jenkins.

## CI Notes

- Changing any file in this repository and commit will trigger a new build in Jenkins.
- Deployment is handled by the Jenkins build pipeline.
- The .openshift directory stores the server configuration files.