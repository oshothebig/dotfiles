set shell := ["bash", "-uc"]

config_dir := home_directory() / ".config"

default:
    just --list

zsh: (_dotfile "zshrc")

git: (_dotfile "gitconfig")

_dotfile TARGET:
    if [[ -e {{home_directory()}}/.{{TARGET}} ]]; then \
        echo "{{home_directory() }}.{{TARGET}} exists, do nothing"; \
    else \
        ln -s {{justfile_directory()}}/{{TARGET}} {{home_directory()}}/.{{TARGET}}; \
    fi

bat: (_config "bat")

helix: (_config "helix")

ghostty: (_config "ghostty")

_config TARGET:
    # Create ~/.config directory if not exists
    if [[ ! -d {{config_dir}} ]]; then \
        mkdir -p {{config_dir}}; \
    fi

    # Create a symlink for the target config
    if [[ -d {{config_dir}}/{{TARGET}} ]]; then \
        echo "{{config_dir}}/{{TARGET}} exists, do nothing"; \
    else \
        ln -s {{justfile_directory()}}/{{TARGET}} {{config_dir}}/{{TARGET}}; \
    fi
