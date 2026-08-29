[![CI](https://github.com/onemorepereira/fedora_workstation_builder/actions/workflows/ci.yaml/badge.svg)](https://github.com/onemorepereira/fedora_workstation_builder/actions/workflows/ci.yaml)

# Fedora workstation builder

An Ansible role that takes a Fedora machine from _fresh install_ to _ready-to-rock-n-roll_: users and sudo, SSH keys and config, extra RPM repos, baseline packages, and version-pinned third-party tools.

Supports currently maintained Fedora releases (43/44) and requires **ansible-core ≥ 2.16**.

## Quick start

```bash
# one-time: install the required collections
ansible-galaxy collection install -r requirements.yml

# build THIS machine from the example blueprint
ansible-playbook play_local.yaml -e @examples/profile.yaml -e sys_user=$USER --ask-become-pass
```

To build a remote machine, point `play.yaml` at an inventory instead:

```bash
ansible-playbook play.yaml -i inventory -e @my-profile.yaml -e sys_user=jane
```

## Project structure

```
.
├── play.yaml                   # playbook for remote hosts
├── play_local.yaml             # playbook for the local machine
├── requirements.yml            # required Ansible collections
├── examples/
│   ├── profile.yaml            # example blueprint — copy and customize
│   └── secrets.yaml.example    # template for your vault-encrypted secrets
├── docker/                     # podman-based test harness (see Makefile)
└── roles/fedora_workstation/
    ├── defaults/main.yml       # tunable defaults
    ├── tasks/
    │   ├── 00-users.yaml       # system user, wheel + NOPASSWD sudo, gitconfig
    │   ├── 10-system.yaml      # hostname, SSH keys/config, repos, updates, base packages
    │   ├── 20-tools.yaml       # extra packages and pinned binary tools
    │   └── 30-repos.yaml       # source-code repo cloning (opt-in via get_repos)
    ├── templates/              # gitconfig.j2, ssh-config.j2
    └── files/yum-repos/        # *.repo files copied verbatim to /etc/yum.repos.d
```

## Blueprints (profiles)

Your profile is **your** configuration. Copy `examples/profile.yaml` and edit. Key settings:

Configuration key | Description
------------------|------------
`sys_user` | **Required.** The workstation user being built (created if missing, added to `wheel`)
`basic_updates` | `true`/`false` — run a full package update
`reboot` | `true`/`false` — reboot after the update when it changed anything
`get_repos` | `true`/`false` — clone the configured source-code repos
`public_key_value` | Your **public** SSH key; added to `root` and `sys_user` authorized_keys
`sys_user_email`, `git_nickname` | Used to render `~/.gitconfig`
`default_identity_key_file` | Default identity referenced from the generated `~/.ssh/config`
`dnf_basic` | Baseline package list (see `defaults/main.yml`)
`dnf_extras` | Additional packages — prefer Fedora packages (`awscli2`, `kubernetes-client`, …) over download URLs
`binaries_remote_archived` | `{name: url}` zip/tar archives exploded into `/usr/local/bin` — pin exact versions
`binaries_remote` | `{name: {url, checksum}}` single binaries installed to `/usr/local/bin` with checksum verification
`key_based_git_repos`, `http_based_git_repos` | Repos cloned under `~/Extra/repos/<class>/<name>`
`bastions` | Optional SSH bastion/proxy definitions for `~/.ssh/config`

## Secrets

Secrets (private keys) never live in this repo. Start from the template and encrypt with Vault:

```bash
cp examples/secrets.yaml.example secrets.yaml   # git-ignored
ansible-vault encrypt secrets.yaml
ansible-playbook play_local.yaml -e @my-profile.yaml -e @secrets.yaml --ask-vault-pass
```

## Testing

Lint and converge run in CI (GitHub Actions) against Fedora 43 and 44 containers, plus a monthly scheduled canary. Locally:

```bash
make lint            # yamllint + ansible-lint
make build run test  # converge against a podman container over SSH
make clean
```
