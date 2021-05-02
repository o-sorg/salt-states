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

# only look for this environments
gitfs_saltenv_whitelist:
  - base
  - dev
  - qa

# only load branches
gitfs_refspecs:
  - "+refs/heads/*:refs/remotes/origin/*"

# general git config
gitfs_global_lock: False
gitfs_update_interval: 60

# saltenv = pillarenv
pillarenv_from_saltenv: True

# default pillar dir config
pillar_roots:
  base:
    - /srv/pillar

ext_pillar:
  - git:
      - git://github.com/o-sorg/salt-states.git

# only load branches
git_pillar_refspecs:
  - "+refs/heads/*:refs/remotes/origin/*"

# main is the new master
git_pillar_branch: main
git_pillar_base: main

# load pillars form pillar subdir
git_pillar_root: pillar

# we don't need to be smart..
pillar_source_merging_strategy: none
# master fs Pillar wins
ext_pillar_first: True

# disable global lock in single-master deployment
git_pillar_global_lock: False
```
