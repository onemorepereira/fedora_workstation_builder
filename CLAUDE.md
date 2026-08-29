# fedora_workstation_builder

Ansible role that bootstraps a Fedora workstation. Targets currently supported Fedora releases (43/44) and ansible-core ≥ 2.16.

## Conventions

- Everything is FQCN (`ansible.builtin.*`, `ansible.posix.*`); collections are pinned in `requirements.yml`.
- Package installs use `ansible.builtin.package` so the dnf5 backend is auto-selected on Fedora 41+.
- Third-party binaries are version-pinned; single binaries carry sha256 checksums (`binaries_remote`). Prefer Fedora packages (`dnf_extras`) over download URLs when one exists.
- No `ignore_errors`, no `validate_certs: no` — failures must surface.
- Task files run in numeric order via `import_tasks` in `roles/fedora_workstation/tasks/main.yaml`.
- The `hostname` and `reboot` tasks are guarded so the role converges inside containers (CI).

## Verify changes

```bash
make lint                                  # yamllint + ansible-lint (see .ansible-lint / .yamllint)
ansible-playbook play_local.yaml --syntax-check -e sys_user=test
make build run test                        # full converge against a podman container
```

CI (.github/workflows/ci.yaml) runs lint + converge on fedora:43/44 containers and a monthly scheduled canary. Keep the Fedora version matrix current when new releases ship (~every 6 months).

## Work tracking

Plane project: **Fedora Workstation Builder (FWB)**.
