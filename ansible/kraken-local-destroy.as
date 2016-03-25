#!/usr/bin/env ANSIBLE_HOSTS="localhost," ANSIBLE_CONNECTION=local CALLBACK_PLUGINS=callback_plugins ANSIBLE_STDOUT_CALLBACK=skippy ansible-playbook -v
# vim:ft=yaml
---
- name: destroy kraken locally
  hosts: localhost
  roles:
    - { role: kraken-local,  apply_terraform: false }
