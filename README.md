# Salt git scaffolding

Master config file layout:

```bash
/srv
├── pillar
│   ├── default.sls
│   └── top.sls
└── salt
    ├── common
    │   ├── init.sls
    │   └── packages.sls
    └── top.sls
```

```yaml
# file: /srv/salt/top.sls
# This top.sls will overwrite all top.sls coming from git
# A highstate without an explicite saltenv will only do what is in this file.
# salt 'hostname' state.apply => only base from this file
# salt 'hostname' state.apply saltenv=dev => only dev from git branch dev
# salt 'hostname' state.apply saltenv=qa => only qa from git branch qa

# overwrite top.sls from git branch main
base:
  "*":
    - common
    - echo

# overwrite top.sls from git branch dev
dev:
  "nomatch":
    - noop

# overwrite top.sls from git branch qa
qa:
  "nomatch":
    - noop
```

```yaml
# file: /etc/salt/master

# base is the default
default_top: base
# important to have actual staging, 'same' would brake this.
top_file_merging_strategy: merge

# base is also on master fs
file_roots:
  base:
    - /srv/salt/

# look on master fs first then in git
fileserver_backend:
  - roots
  - gitfs

# git repo config
gitfs_remotes:
  - git://github.com/o-sorg/salt-states.git

# only search in branches for envs
gitfs_ref_types:
  - branch

# base is in main branch
gitfs_base: main

# states are in the subfolder states
gitfs_root: states

# only look in this branches for envs
gitfs_env_whitelist:
  - main
  - dev
  - qa

# general git config
gitfs_global_lock: False
gitfs_update_interval: 60

# pillar config

pillarenv_from_saltenv: True
pillar_roots:
  base:
    - /srv/pillar
ext_pillar:
  - git:
      - git://github.com/o-sorg/salt-states.git

git_pillar_refspecs:
  - "+refs/heads/*:refs/remotes/origin/*"

git_pillar_branch: main
git_pillar_base: main
git_pillar_root: pillar

pillar_source_merging_strategy: none

git_pillar_global_lock: False
```
