PREFIX ?= /usr

install:
	install -d $(PREFIX)/bin
	install -m 755 hdd-spindown.sh $(PREFIX)/bin/hdd-spindown.sh
	install -d $(PREFIX)/etc
	install -m 644 hdd-spindown.rc $(PREFIX)/etc/hdd-spindown.rc
	install -d $(PREFIX)/lib/systemd/system
	install -m 644 hdd-spindown.service $(PREFIX)/lib/systemd/system/hdd-spindown.service


.PHONY: install

