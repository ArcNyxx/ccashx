#!/bin/sh
# ccashx - ccash command client
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

.POSIX:

include config.mk

clean:
	rm -rf ccashx-$(VERSION).tar.gz

dist: clean
	mkdir -p ccashx-$(VERSION)
	cp -R LICENCE README Makefile config.mk ccashx.sh arg.conf cmd.conf \
		ccashx.1 ccashx-$(VERSION)
	tar -cf ccashx-$(VERSION).tar ccashx-$(VERSION)
	gzip ccashx-$(VERSION).tar
	rm -rf ccashx-$(VERSION)

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin $(DESTDIR)$(MANPREFIX)/man1 \
		$(DESTDIR)$(SCRPREFIX)/ccashx
	sed "s|SCRPREFIX|$(SCRPREFIX)/ccashx|g" < ccashx.sh \
		> $(PREFIX)/bin/ccashx
	chmod 755 $(DESTDIR)$(PREFIX)/bin/ccashx
	sed "s/VERSION/$(VERSION)/g" < ccashx.1 > $(MANPREFIX)/man1/ccashx.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/ccashx.1
	cp -f *.conf $(DESTDIR)$(SCRPREFIX)/ccashx
	chmod 644 $(DESTDIR)$(SCRPREFIX)/ccashx/*

uninstall:
	rm -rf $(DESTDIR)$(PREFIX)/bin/ccashx $(DESTDIR)$(MANPREFIX)/man1/ccashx.1 \
		$(DESTDIR)$(SCRPREFIX)/ccashx

.PHONY: clean dist install uninstall
