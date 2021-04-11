TARGETS := tmux vim

.PHONY: install
install: $(TARGETS)

.PHONY: $(TARGETS)

# Define config file for each target
tmux: tmux.conf
vim: vimrc

# Recipe to create a symlink appending "." at the begining of the file name
$(TARGETS):
	$(eval dotfile := .$<)
	test -f ~/$(dotfile) || ln -s $(CURDIR)/$< ~/$(dotfile)

clean:
	unlink ~/.tmux.conf
