# ------------------
# ANSIBLE-MAKEFILE v0.13.0
# Run ansible commands with ease
# ------------------
#
# Copyright (C) 2017 Paul(r)B.r
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

##
# VARIABLES
##
playbook   ?= setup.yml
env        ?= hosts
mkfile_dir ?= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ifneq ("$(tag)", "")
  opts     := $(opts) --tag="$(tag)"
endif

##
# TASKS
##
.PHONY: install
install: ## make install [roles_path=roles/] # Install roles dependencies
	@ansible-galaxy role install --role-file requirements.yml
	@ansible-galaxy collection install --requirements-file requirements.yml

.PHONY: inventory
inventory: ## make inventory [provider=<ec2|gce...>] [env=hosts] # Download dynamic inventory from Ansible's contrib
	@wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/$(provider).py
	@chmod +x $(provider).py
	mv $(provider).py $(env)

.PHONY: lint
lint: ## make lint [playbook=setup] [env=hosts] [args=<ansible-playbook arguments>] # Check syntax of a playbook
	@env=$(env) ansible-playbook --inventory-file="$(env)" --syntax-check $(opts) "$(playbook)"

.PHONY: debug
debug: mandatory-host-param ## make debug host=hostname [env=hosts] [args=<ansible arguments>] # Debug a host's variable
	@env=$(env) ansible -i $(env) $(opts) -m setup $(host)
	@env=$(env) ansible --inventory-file="$(env)" $(opts) --module-name="debug" --args="var=hostvars[inventory_hostname]" $(host)

.PHONY: dry-run
dry-run: ## make dry-run [playbook=setup] [env=hosts] [tag=<ansible tag>] [args=<ansible-playbook arguments>] # Run a playbook in dry run mode
	@env=$(env) ansible-playbook --inventory-file="$(env)" --diff --check $(opts) "$(playbook)" --limit $(shell hostname)

.PHONY: run
run: ## make run [playbook=setup] [env=hosts] [tag=<ansible tag>] [args=<ansible-playbook arguments>] # Run a playbook
	@env=$(env) ansible-playbook --inventory-file="$(env)" --diff $(opts) "$(playbook)" --limit $(shell hostname)

group ?=all
.PHONY: list
list: ## make list [group=all] [env=hosts] # List hosts inventory
	@env=$(env) ansible --inventory-file="$(env)" $(group) --list-hosts

.PHONY: vault
vault: mandatory-file-param ## make vault file=/tmp/vault.yml [env=hosts] [args=<ansible-vault arguments>] # Edit or create a vaulted file
	@[ -f "$(file)" ] && env=$(env) ansible-vault edit $(opts) "$(file)" || \
	env=$(env) ansible-vault create $(opts) "$(file)"

.PHONY: console
console: ## make console [env=hosts] [args=<ansible-console arguments>] # Run an ansible console
	@env=$(env) ansible-console --inventory-file="$(env)" $(opts)

group ?=all
.PHONY: facts
facts: ## make facts [group=all] [env=hosts] [args=<ansible arguments>] # Gather facts from your hosts
	@env=$(env) ansible --module-name="setup" --inventory-file="$(env)" $(opts) --tree="out/" $(group)

.PHONY: tags
tags: ## make facts [env=hosts] [args=<ansible arguments>] # List all tags available in the playbook
	@env=$(env) ansible-playbook --inventory-file="$(env)" $(opts) --list-tags "$(playbook)"

.PHONY: cmdb
cmdb: ## make cmdb # Create HTML inventory report
	@ansible-cmdb "out/" > list-servers.html

.PHONY: bootstrap
bootstrap: ## make bootstrap # Install ansible (Ubuntu only)
	@apt-get install -y software-properties-common && \
	apt-add-repository ppa:ansible/ansible && \
	apt-get update && \
	apt-get install -y ansible

.PHONY: mandatory-host-param mandatory-file-param
mandatory-host-param:
	@[ ! -z $(host) ]
mandatory-file-param:
	@[ ! -z $(file) ]

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
