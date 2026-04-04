set shell := ["bash", "-uc"]

config_dir := home_directory() / ".config"

default:
    just --list

install: zsh ssh git bat helix ghostty sheldon

uninstall:
    unlink {{home_directory()}}/.zshrc
    unlink {{home_directory()}}/.ssh/config
    unlink {{config_dir}}/git/config
    unlink {{config_dir}}/bat
    unlink {{config_dir}}/helix
    unlink {{config_dir}}/ghostty
    unlink {{config_dir}}/sheldon

zsh: (_dotfile "zshrc")

ssh:
    # Create ~/.ssh directory if not exists
    if [[ ! -d {{home_directory()}}/.ssh ]]; then \
        mkdir -p {{home_directory()}}/.ssh; \
    fi

    # Create a symlink to ~/.ssh/config
    if [[ ! -f {{home_directory()}}/.ssh/config ]]; then \
        ln -s {{justfile_directory()}}/ssh/config {{home_directory()}}/.ssh/config; \
    fi

git:
    # Create ~/.config/git directory if not exists
    if [[ ! -d {{config_dir}}/git ]]; then \
        mkdir -p {{config_dir}}/git; \
    fi

    # Create a symlink to ~/.config/git/config
    if [[ ! -e {{config_dir}}/git/config ]]; then \
        ln -s {{justfile_directory()}}/git/config {{config_dir}}/git/config; \
    else \
        echo "{{config_dir}}/git/config exists, do nothing"; \
    fi

_dotfile TARGET:
    if [[ -e {{home_directory()}}/.{{TARGET}} ]]; then \
        echo "{{home_directory() }}.{{TARGET}} exists, do nothing"; \
    else \
        ln -s {{justfile_directory()}}/{{TARGET}} {{home_directory()}}/.{{TARGET}}; \
    fi

bat: (_config "bat")

helix: (_config "helix")

ghostty: (_config "ghostty")

sheldon: (_config "sheldon")

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
