echo:
   cmd.run:
     - name: /usr/bin/echo "{{ pillar['environment'] }}"