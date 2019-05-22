GIT2LOG := $(shell if [ -x ./git2log ] ; then echo ./git2log --update ; else echo true ; fi)
GITDEPS := $(shell [ -d .git ] && echo .git/HEAD .git/refs/heads .git/refs/tags)
VERSION := $(shell $(GIT2LOG) --version VERSION ; cat VERSION)
BRANCH  := $(shell [ -d .git ] && git branch | perl -ne 'print $$_ if s/^\*\s*//')
PREFIX  := FirmwareUpdateKit-$(VERSION)
BINDIR   = /usr/bin

.PHONY: all clean install

all:

archive: changelog
	@if [ ! -d .git ] ; then echo no git repo ; false ; fi
	mkdir -p package
	git archive --prefix=$(PREFIX)/ $(BRANCH) > package/$(PREFIX).tar
	tar -r -f package/$(PREFIX).tar --mode=0664 --owner=root --group=root --mtime="`git show -s --format=%ci`" --transform='s:^:$(PREFIX)/:' VERSION changelog
	xz -f package/$(PREFIX).tar

changelog: $(GITDEPS)
	$(GIT2LOG) --changelog changelog

install:
	install -d -m 755 $(DESTDIR)/usr/share/FirmwareUpdateKit
	install -m 644 dosfiles/* $(DESTDIR)/usr/share/FirmwareUpdateKit
	install -m 755 -D fuk $(DESTDIR)$(BINDIR)
	perl -pi -e 's/<VERSION>/$(VERSION)/' $(DESTDIR)$(BINDIR)/fuk

clean:
	@rm -rf *~ package changelog VERSION
