.PHONY: install
install:
	test -f ~/.tmux.conf || ln -s $(CURDIR)/tmux.conf ~/.tmux.conf

clean:
	unlink ~/.tmux.conf
