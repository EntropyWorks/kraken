#!/usr/bin/env ANSIBLE_HOSTS="localhost," ANSIBLE_CONNECTION=local CALLBACK_PLUGINS=callback_plugins ANSIBLE_STDOUT_CALLBACK=skippy ansible-playbook -v  -connection=local
# vim:ft=yaml
---
- name: apply kraken locally
  hosts: localhost
  roles:
    - { role: dochang.docker }
    - { role: kraken-local,  apply_terraform: true }
