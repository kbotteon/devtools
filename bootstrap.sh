################################################################################
# Entry point for GH dotfile setup mechanism to automatically install devtools
################################################################################

DEFAULT_DEVTOOLS_PATH='/persist/sandboxes/devtools'

# Check if we've already done this via the devcontainer.json
if [[ -d ${DEFAULT_DEVTOOLS_PATH} ]]; then
    exit
fi
