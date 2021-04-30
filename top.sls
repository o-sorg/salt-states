# This is the QA environment state tree for testing
# Anyone should be able to run this state tree on any supported platform when
# it is complete

base:
  '*':
    - core
  'kernel:Linux':
    - match: grain
    - kernel

dev:
  'minion1':
    - python
    - files
    - ldap
    - files.ext-files-second
    
qa:
  'minion2':
    - python
    - files
    - ldap
    - files.ext-files-second
