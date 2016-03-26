#!/usr/bin/env ANSIBLE_HOSTS="localhost," ANSIBLE_CONNECTION=local ansible-playbook -vv -connection=local
# vim:ft=yaml
---
- name: destroy kraken locally
  hosts: localhost
  roles:
    - { role: kraken-local,  apply_terraform: false }
