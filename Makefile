TARGETS := zsh git

.PHONY: install
install: $(TARGETS) bat gpg helix ghostty sheldon

.PHONY: $(TARGETS) bat gpg helix ghostty sheldon

# Define config file for each target
zsh: zshrc
git: gitconfig

# specific config directory
gpg: | ~/.gnupg
~/.gnupg:
	mkdir -p $@
	chmod 700 $@

bat helix ghostty: | ~/.config
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

helix:
	test -L ~/.config/$@ || ln -s $(CURDIR)/$@ ~/.config/$@

ghostty:
	test -L ~/.config/$@ || ln -s $(CURDIR)/$@ ~/.config/$@

sheldon:
	test -L ~/.config/$@ || ln -s $(CURDIR)/$@ ~/.config/$@
