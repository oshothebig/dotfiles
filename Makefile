TARGETS := zsh tmux vim

.PHONY: install
install: $(TARGETS) bat

.PHONY: $(TARGETS) bat

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

clean:
	unlink ~/.tmux.conf
