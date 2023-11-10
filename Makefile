BASE_PKGS	:= vim-common build-essential curl wget
BASE_PKGS += libreadline-dev libncursesw5-dev libssl-dev libsqlite3-dev libgdbm-dev libbz2-dev liblzma-dev zlib1g-dev uuid-dev libffi-dev libdb-dev tk8.6-dev
# BASE_PKGS	+= pciutils psmisc shadow util-linux bzip2 gzip xz licenses pacman systemd systemd-sysvcompat 
PACMAN		:= sudo pacman -S
APTUPDATE	:= sudo apt update
APTINSTALL	:= sudo apt install 
SYSTEMD_ENABLE	:= sudo systemctl --now enable

.DEFAULT_GOAL := help
.PHONY: all allinstall nextinstall allupdate allbackup

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: allinstall nextinstall allupdate allbackup

${HOME}/.local:
	mkdir -p $<

ssh: ## Init ssh
	mkdir -p ${HOME}/.$@
	cp -rf ~/Dropbox/Home/.$@ ${HOME}/
	chmod 600 ${HOME}/.ssh/id_rsa

init: ## Initial deploy dotfiles
	ln -vsf ${PWD}/.lesskey ${HOME}/.lesskey
	lesskey
	for item in zshrc vimrc bashrc npmrc myclirc tmux.conf screenrc aspell.conf gitconfig netrc authinfo; do
		ln -vsf {${PWD},${HOME}}/.$$item
	done
	ln -vsf {${PWD},${HOME}}/.config/hub

base: ## Install base and base-devel package
	$(APTUPDATE)
	$(APTINSTALL) $(BASE_PKGS)

install:
	$(APTUPDATE)
	$(APTINSTALL) $(BASE_PKGS)

backup:
	mkdir -p ${PWD}/ubuntu

tmux:
	$(APTUPDATE)
	$(APTINSTALL) $@
	cp ${HOME}/Dropbox/Home/.tmux.conf ${HOME}/.tmux.conf
# ln -sf ${HOME}/.tmux ${HOME}/Dropbox/Home/.tmux

codecs:
	$(APTUPDATE)
	$(APTINSTALL) ubuntu-restricted-extras

tools:
	$(APTUPDATE)
	$(APTINSTALL) gnome-tweaks meld keepassxc
	sudo timedatectl set-local-rtc true
	sudo hwclock --verbose --systohc --localtime 
	gsettings set org.gnome.nautilus.preferences always-use-location-entry true
#powerLine font
	git clone https://github.com/powerline/fonts.git --depth=1
	./fonts/install.sh
	rm -rf fonts
	$(APTINSTALL)powerline
	echo "if [ -f /usr/share/powerline/bindings/bash/powerline.sh ]; then" >> ${HOME}/.bashrc
	echo "  powerline-daemon -q" >> ${HOME}/.bashrc
	echo "  POWERLINE_BASH_CONTINUATION=1" >> ${HOME}/.bashrc
	echo "  POWERLINE_BASH_SELECT=1" >> ${HOME}/.bashrc
	echo "  source /usr/share/powerline/bindings/bash/powerline.sh" >> ${HOME}/.bashrc
	echo "fi" >> ${HOME}/.bashrc
