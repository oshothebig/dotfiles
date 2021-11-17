TARGETS := zsh tmux vim git

.PHONY: install
install: $(TARGETS) bat gpg

.PHONY: $(TARGETS) bat gpg

# Define config file for each target
zsh: zshrc
tmux: tmux.conf
vim: vimrc
git: gitconfig

# specific config directory
gpg: | ~/.gnupg
~/.gnupg:
	mkdir -p $@

bat: | ~/.config
~/.config:
	mkdir -p $@

# Recipe to create a symlink appending "." at the begining of the file name
$(TARGETS):
	$(eval dotfile := .$<)
	test -f ~/$(dotfile) || ln -s $(CURDIR)/$< ~/$(dotfile)

bat:
	test -L ~/.config/$@ || ln -s $(CURDIR)/$@ ~/.config/$@

gpg:
	test -f ~/.gnupg/gpg-agent.conf || ln -s $(CURDIR)/gnupg/gpg-agent.conf ~/.gnupg/gpg-agent.conf

clean:
	unlink ~/.tmux.conf
