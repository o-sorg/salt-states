
coreutils:
  pkg.installed

echo:
   cmd.run:
     - name: echo "{{ pillar['environment'] }}"