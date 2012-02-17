GIT2LOG := $(shell if [ -x ./git2log ] ; then echo ./git2log --update ; else echo true ; fi)
GITDEPS := $(shell [ -d .git ] && echo .git/HEAD .git/refs/heads .git/refs/tags)

VERSION := $(shell $(GIT2LOG) --version VERSION ; cat VERSION)

.PHONY: all clean install

all: changelog

changelog: $(GITDEPS)
	$(GIT2LOG) --changelog changelog

install: all
	install -d -m 755 $(DESTDIR)/usr/share/FirmwareUpdateKit
	install -m 644 dosfiles/* $(DESTDIR)/usr/share/FirmwareUpdateKit
	install -d -m 755 $(DESTDIR)/usr/bin
	install -m 755 fuk $(DESTDIR)/usr/bin
	perl -pi -e 's/<VERSION>/$(VERSION)/' $(DESTDIR)/usr/bin/fuk

clean:
	@rm -f *~ */*~

