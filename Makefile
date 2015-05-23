PREFIX ?= /usr

install:
	install -d $(PREFIX)/bin
	install -m 755 hdd-spindown.sh $(PREFIX)/bin/hdd-spindown.sh
	install -d $(PREFIX)/lib/systemd/system
	install -m 644 hdd-spindown.sh.service $(PREFIX)/lib/systemd/system/hdd-spindown.sh.service


.PHONY: install

