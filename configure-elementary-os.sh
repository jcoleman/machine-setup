#! /bin/bash

# Stop the Pantheon terminal from stealing CTRL-V from Vim.
# (for system copy/paste use CTRL-SHIFT-{C,V}
gsettings set io.elementary.terminal.settings natural-copy-paste false
