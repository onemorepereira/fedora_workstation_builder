# Fedora workstation builder
This project is intended to help teams and individuals currently using a Fedora Project or derivative distribution of Linux to shorten the time it takes to go from _fresh install_ to _ready-to-rock-n-roll!_

Its intended to become flexible and modular by leveraging Ansible best practices, while remaining simple to clone and run to get immediate results. 

### Basic project structure

```
.
├── files
│   └── yum-repos
├── samples
│   └── tomsawyer.yml
├── tasks
│   └── fedora-main.yml
├── templates
│   ├── boto-config.j2
│   ├── gitconfig.j2
│   └── ssh-config.j2
└── vars
    ├── code-repo-lists.yml
    ├── ssh-tunneling.yml
    └── vault
        └── secrets.yaml
```

### Sample call
```bash
ansible-playbook ./tasks/fedora-main.yml \ 
--extra-vars @./samples/tomsawyer.yml \
--ask-sudo --ask-vault
```

----

### Repo Anatomy
#### Files
```
.
└── files
    └── yum-repos
```
This directoy should hold any `dnf` repositories that you would like to include on your system build. These are traditional _YUM/DNF_ repo files that will be copied _verbatim_ under `/etc/yum.repos.d`. Files placed here must have an `.repo` extension to be processed.

We've included a basic set of repositories in order to enable our sample configuration to be tested via Jenkins. Your mileage may vary.

----

#### Tasks
```
└── tasks
    └── fedora-main.yml
```
This is the _meat_ of the project. The main playbook that is directly invoked to run the builder.

----

#### Templates
```
└── templates
    ├── boto-config.j2
    ├── gitconfig.j2
    └── ssh-config.j2
```
Templates provide flexibility to customize configuration files.

* `boto-config.j2` to provide a customizable _AWS BOTO_ profile to use out of the box
* `gitconfig.j2` to provide out of the box command aliasing and _git_ customizations; can anyone survive without _git_ nowadays?
* `ssh-config.j2` to customize your _ssh configuration_, for instance, to create multiple custom-bastion/proxy sections

----

#### Var & Secret files
```
└── vars
    ├── code-repo-lists.yml
    ├── ssh-tunneling.yml
    └── vault
        └── secrets.yaml
```
_Var_ files can store anythig, ranging from simple key:value pairs to complex multi-level dictionary structures. Their common denominator is that we are not keeping any sensitive information here.

_Secret_ files on the other hand, are intended to store our sensitive data. As a rule of thumb, you should **NEVER** commit your secret files back into source control. Here is where we store keys & passwords.

_We provide a secrets file out of the box in our case just as an example. The secrets file we provide is protected by a very weak passphrase. The passphrase is **password**. You have been warned: DO NOT COMMIT YOUR SECRET FILE_

Var file|Description
--------|-----------
code-repo-lists.yml|_coming soon_
ssh-tunneling.yml|_coming soon_

----

#### Blueprints
```
└── samples
    └── tomsawyer.
```
_Blueprint_ files provide the configuration details that you'll use. This is **your** configuration management repo. Here is a basic listing of the configuration keys it contains.

Configuration key|Description
-----------------|-----------
`basic_setup`|`true` or `false`; indicates whether to run the basic configuration sections of the builder or skip them
`basic_updates`|`true` or `false`; indicates whether to pull down updates during builder execution or not
`basic_config`|`true` or `false`; indicates whether to check system configuration or not during builder execution
`get_repos`|`true` or `false`; indicates whether to ensure your source code repos/projects are on your local system or not during builder execution
`sys_user`|this is the main system user we are building a profile and rolling out settings for; remember, this is a workstation!
`public_key_value`|provide your _rsa public key_; this will be injected into the local system root user `authorized_keys` to make future management by **you** easier. This is your PUBLIC KEY not your private key.
`sys_user_email`|we can use this value to populate your email address where needed; i.e. your Git profile
`git_nickname`|self-explanatory
`default_identity_key_file`|While building your SSH configuration you can customize the default identity key that is used by `sys_user`
`hashicorp_packer_source_url`|Provide the download URL & for Hashicorp Packer
`hashicorp_packer_source_file`|Provide the local Packer artifact name; the builder will take care of downloading and making Packer available under a usable alias `pkr` if not already present
`boto_aws_region`|Specify your default AWS regions when using Boto (Ansible) for Amazon Web Services
`boto_aws_region_endpoint`|Specify the full endpoint for the corresponding AWS region you picked above.
`dnf_basic`| Provide a YAML list of packages by name or RPM location that you would like to install as part of the core-system setup
`dnf_extras`| Provide a YAML list of packages by name or RPM location that you would like to install; this can sometimes be useful if you run into dependencies that DNF cannot resolve on its own
`pip_basic`|Provide a YAML list of PIP managed packages to install on the system