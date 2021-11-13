TARGETS := zsh tmux vim

.PHONY: install
install: $(TARGETS) bat gpg

.PHONY: $(TARGETS) bat gpg

# Define config file for each target
zsh: zshrc
tmux: tmux.conf
vim: vimrc

# Recipe to create a symlink appending "." at the begining of the file name
$(TARGETS):
	$(eval dotfile := .$<)
	test -f ~/$(dotfile) || ln -s $(CURDIR)/$< ~/$(dotfile)

bat:
	test -f ~/.config/$@ || ln -s $(CURDIR)/$@ ~/.config/$@

gpg:
	test -f ~/.gnupg/gpg-agent.conf || ln -s $(CURDIR)/gnupg/gpg-agent.conf ~/.gnupg/gpg-agent.conf

clean:
	unlink ~/.tmux.conf
