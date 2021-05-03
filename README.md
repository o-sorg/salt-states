# Salt git scaffolding

## Master config

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
# file: /srv/pillar/top.sls

base:
  "*":
    - default
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

# load states for base from salt-master roots
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

# main is the new master..
gitfs_base: main

# load states form states subfolder
gitfs_root: states

# only load branches, ignore tags etc.
gitfs_refspecs:
  - "+refs/heads/*:refs/remotes/origin/*"

# only look in branches for environments
gitfs_ref_types:
  - branch

# only look for this environments
gitfs_saltenv_whitelist:
  - base
  - dev
  - qa

# disable global lock. Best practice in single-master deployments
gitfs_global_lock: False

# update every 60 sec
gitfs_update_interval: 60

# saltenv = pillarenv
pillarenv_from_saltenv: True

# load pillars for base from salt-master roots
pillar_roots:
  base:
    - /srv/pillar

# only load branches, ignore tags etc.
git_pillar_refspecs:
  - "+refs/heads/*:refs/remotes/origin/*"

# only map this branches to environments
ext_pillar:
  - git:
      - main git://github.com/o-sorg/salt-states.git
      - dev git://github.com/o-sorg/salt-states.git
      - qa git://github.com/o-sorg/salt-states.git

# main is the new master..
git_pillar_branch: main
git_pillar_base: main

# load pillars form pillar subfolder
git_pillar_root: pillar

# we don't need to be smart..
pillar_source_merging_strategy: none

# master roots Pillar wins
ext_pillar_first: True

# disable global lock. Best practice in single-master deployments
git_pillar_global_lock: False
```
