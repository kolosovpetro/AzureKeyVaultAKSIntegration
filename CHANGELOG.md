# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning v2.0.0](https://semver.org/spec/v2.0.0.html).

## v1.0.0 - In Progress

### Changed

- Provision AKS cluster terraform
- Provision KeyVault and test secrets terraform
- Configure RBAC access to keyvault in terraform
- Enable keyvault addon in AKS
- Configure csi provider class for keyvault
- Create a pod with mounts pointing to secrets
- Create a pod that loads secrets to environment
- Add enable addon script
