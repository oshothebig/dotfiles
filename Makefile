.PHONY: install
install: tmux

.PHONY: tmux
tmux: tmux.conf
	test -f ~/.tmux.conf || ln -s $(CURDIR)/$< ~/.tmux.conf

clean:
	unlink ~/.tmux.conf
