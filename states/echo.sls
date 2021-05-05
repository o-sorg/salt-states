echo:
   cmd.run:
     - name: echo "{{ pillar['environment'] }}"