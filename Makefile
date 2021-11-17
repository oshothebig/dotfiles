TARGETS := zsh tmux vim

.PHONY: install
install: $(TARGETS) bat gpg git

.PHONY: $(TARGETS) bat gpg git

# Define config file for each target
zsh: zshrc
tmux: tmux.conf
vim: vimrc

# Recipe to create a symlink appending "." at the begining of the file name
$(TARGETS):
	$(eval dotfile := .$<)
	test -f ~/$(dotfile) || ln -s $(CURDIR)/$< ~/$(dotfile)

bat:
	test -L ~/.config/$@ || ln -s $(CURDIR)/$@ ~/.config/$@

gpg:
	test -f ~/.gnupg/gpg-agent.conf || ln -s $(CURDIR)/gnupg/gpg-agent.conf ~/.gnupg/gpg-agent.conf

git:
	test -f ~/.gitconfig || ln -s $(CURDIR)/gitconfig ~/.gitconfig

clean:
	unlink ~/.tmux.conf
