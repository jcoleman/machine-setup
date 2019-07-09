#!/bin/bash

# Allow gdb to attach to other user processes.
# I find this particularly useful for PostgreSQL development so that I can
# (without sudo) attach gdb to the backend process running as the postgres user.
sudo sed -i "s/kernel.yama.ptrace_scope = 1/kernel.yama.ptrace_scope = 0/" /etc/sysctl.d/10-ptrace.conf
