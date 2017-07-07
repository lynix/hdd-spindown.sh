DESTDIR ?= /
PREFIX ?= /usr

install:
	install -D -m 755 hdd-spindown.sh $(DESTDIR)/$(PREFIX)/bin/hdd-spindown.sh
	install -D -m 644 hdd-spindown.rc $(DESTDIR)/etc/hdd-spindown.rc
	install -D -m 644 hdd-spindown.service \
		$(DESTDIR)/$(PREFIX)/lib/systemd/system/hdd-spindown.service


.PHONY: install

