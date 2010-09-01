# Makefile

TRANSLATIONS="it"

all: build

test:
	# Checking for syntax errors
	set -e; for SCRIPT in bin/* hooks/* scripts/live scripts/live-functions scripts/live-helpers scripts/*/*; \
	do \
		sh -n $$SCRIPT; \
	done

	# Checking for bashisms (temporary not failing, but only listing)
	if [ -x /usr/bin/checkbashisms ]; \
	then \
		checkbashisms bin/* hooks/* scripts/live scripts/live-functions scripts/live-helpers scripts/*/* || true; \
	else \
		echo "bashism test skipped - you need to install devscripts."; \
	fi

build:

install: test build
	# Installing configuration
	install -D -m 0644 conf/live.conf $(DESTDIR)/etc/live.conf
	install -D -m 0644 conf/compcache $(DESTDIR)/usr/share/initramfs-tools/conf.d/compcache

	# Installing executables
	mkdir -p $(DESTDIR)/sbin
	cp bin/live-getty bin/live-login bin/live-new-uuid bin/live-snapshot $(DESTDIR)/sbin

	mkdir -p $(DESTDIR)/usr/share/live-initramfs
	cp bin/live-preseed bin/live-reconfigure contrib/languagelist $(DESTDIR)/usr/share/live-initramfs

	mkdir -p $(DESTDIR)/usr/share/initramfs-tools
	cp -r hooks scripts $(DESTDIR)/usr/share/initramfs-tools

	# Installing documentation
	mkdir -p $(DESTDIR)/usr/share/doc/live-initramfs
	cp -r COPYING docs/* $(DESTDIR)/usr/share/doc/live-initramfs

	mkdir -p $(DESTDIR)/usr/share/doc/live-initramfs/examples
	cp -r conf/* $(DESTDIR)/usr/share/doc/live-initramfs/examples


uninstall:
	# Uninstalling configuration
	rm -f $(DESTDIR)/etc/live.conf

	# Uninstalling executables
	rm -f $(DESTDIR)/sbin/live-getty $(DESTDIR)/sbin/live-login $(DESTDIR)/sbin/live-snapshot
	rm -rf $(DESTDIR)/usr/share/live-initramfs
	rm -f $(DESTDIR)/usr/share/initramfs-tools/hooks/live
	rm -rf $(DESTDIR)/usr/share/initramfs-tools/scripts/live*
	rm -f $(DESTDIR)/usr/share/initramfs-tools/scripts/local-top/live

	# Uninstalling documentation
	rm -rf $(DESTDIR)/usr/share/doc/live-initramfs


update:
	set -e; for FILE in docs/parameters.txt; \
	do \
		sed -i	-e 's/2007\\-11\\-19/2007\\-11\\-26/' \
			-e 's/2007-11-19/2007-11-26/' \
			-e 's/19.11.2007/26.11.2007/' \
			-e 's/1.113.1/1.113.2/' \
		$$FILE; \
	done

	# Update language list
	wget -O "contrib/languagelist" \
		"http://svn.debian.org/viewsvn/*checkout*/d-i/trunk/packages/localechooser/languagelist"

clean:

distclean:

reinstall: uninstall install
