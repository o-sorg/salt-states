# Salt git scaffolding

With this setup we can test and develop in a defined set of git branches (e.g. dev and qa) and run tests against any machines like this:
`salt 'hostname' state.apply saltenv=dev` ; without interfering with the production (`base`) environment.

Once changes are merged into the `main` branch **and the new state is added to `/srv/salt/top.sls`**, changed/new states are available in highstates without setting the environment explicit with `saltenv`.

## Salt Master setup

```bash
/srv
├── pillar
│   ├── default.sls         # empty by default
│   └── top.sls             # overwrite
└── salt
    ├── common              # local state example
    │   ├── init.sls
    │   └── packages.sls
    └── top.sls             # highstate top.sls, make sure to add new states here, once they should be available in prod!
```

```yaml
# file: /srv/pillar/top.sls
# This can be used to overwrite pillars coming from git by adding those to the default.sls for examle.
# !! Local pillars will take precedence.
# Pillars that are not locally available will be loaded from the main git branch.

base:
  "*":
    - default # empty by default, can be used to overwrite pillars coming from git
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
    # - add new states here once they should go to prod

# overwrite top.sls from git branch dev, so it does not interfere with the base environment
dev:
  "nomatch": # matches nothing
    - noop # does nothing

# overwrite top.sls from git branch qa, so it does not interfere with the base environment
qa:
  "nomatch": # matches nothing
    - noop # does nothing
```

```yaml
# file: /etc/salt/master

# base is the default environment
default_top: base
# to have staging this needs to be 'merge', 'same' would brake this.
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

## Testing

```bash
# Clear cache and reload pillars:
salt 'testmachine' saltutil.clear_cache
salt 'testmachine' saltutil.refresh_pillar

# Testing in dev
salt 'testmachine' pillar.items saltenv=dev
salt 'testmachine' state.show_top saltenv=dev
salt 'testmachine' state.apply saltenv=dev

# Testing in qa
salt 'testmachine' pillar.items saltenv=qa
salt 'testmachine' state.show_top saltenv=qa
salt 'testmachine' state.apply saltenv=qa

```
