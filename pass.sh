#!/bin/sh
export OP_ACCOUNT='my.1password.eu'
OP_VAULT_NAME='Private'
VAULT_ANSIBLE_NAME='ansible-workstation Vault'
op item get --vault "${OP_VAULT_NAME?}" "${VAULT_ANSIBLE_NAME?}" --fields password --reveal
