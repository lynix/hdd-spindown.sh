PREFIX ?= /usr

install:
	install -d $(PREFIX)/sbin
	install -m 755 hdd-spindown.sh $(PREFIX)/sbin/hdd-spindown.sh


.PHONY: install

