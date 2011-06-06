VERSION=0.0.0
BUILD=1

PYTHON=$(shell which python2.7 || which python27 || which python2.6 || which python26 || which python)
PYTHON_VERSION=$(shell ${PYTHON} -c "from distutils.sysconfig import get_python_version; print(get_python_version())")

prefix=/usr/local
bindir=${prefix}/bin
libdir=${prefix}/lib
pydir=$(shell ${PYTHON} pydir.py ${libdir})
mandir=${prefix}/share/man

all:

clean:
	rm -rf \
		control *.deb \
		setup.py build dist *.egg *.egg-info \
		*.pyc \
		man/man*/*.html

install: install-lib install-man

install-lib:
	install -m644 cloudformation.py $(DESTDIR)$(pydir)/
	PYTHONPATH=$(DESTDIR)$(pydir) $(PYTHON) -mcompileall \
		$(DESTDIR)$(pydir)/cloudformation.py

install-man:
	install -d $(DESTDIR)$(mandir)/man7
	install -m644 man/man7/python-cloudformation.7 $(DESTDIR)$(mandir)/man7/

uninstall: uninstall-lib uninstall-man

uninstall-lib:
	rm -f \
		$(DESTDIR)$(pydir)/cloudformation.py \
		$(DESTDIR)$(pydir)/cloudformation.pyc

uninstall-man:
	rm -f $(DESTDIR)$(mandir)/man7/python-cloudformation.7
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(mandir)/man7

build:
	sudo make deb
	make pypi

deb:
	[ "$$(whoami)" = "root" ] || false
	m4 \
		-D__PYTHON__=python$(PYTHON_VERSION) \
		-D__VERSION__=$(VERSION)-$(BUILD)py$(PYTHON_VERSION) \
		control.m4 >control
	debra create debian control
	make install prefix=/usr DESTDIR=debian
	chown -R root:root debian
	debra build debian python-cloudformation_$(VERSION)-$(BUILD)py$(PYTHON_VERSION)_all.deb
	debra destroy debian

pypi:
	m4 -D__VERSION__=$(VERSION) setup.py.m4 >setup.py
	$(PYTHON) setup.py bdist_egg

deploy: deploy-deb deploy-pypi

deploy-deb:
	scp -i ~/production.pem python-cloudformation_$(VERSION)-$(BUILD)py$(PYTHON_VERSION)_all.deb ubuntu@packages.devstructure.com:
	make deploy-deb-$(PYTHON_VERSION)
	ssh -i ~/production.pem -t ubuntu@packages.devstructure.com "rm python-cloudformation_$(VERSION)-$(BUILD)py$(PYTHON_VERSION)_all.deb"

deploy-deb-2.6:
	ssh -i ~/production.pem -t ubuntu@packages.devstructure.com "reprepro-includedeb debian lenny python-cloudformation_$(VERSION)-$(BUILD)py$(PYTHON_VERSION)_all.deb"
	ssh -i ~/production.pem -t ubuntu@packages.devstructure.com "reprepro-includedeb debian squeeze python-cloudformation_$(VERSION)-$(BUILD)py$(PYTHON_VERSION)_all.deb"
	ssh -i ~/production.pem -t ubuntu@packages.devstructure.com "reprepro-includedeb ubuntu lucid python-cloudformation_$(VERSION)-$(BUILD)py$(PYTHON_VERSION)_all.deb"
	ssh -i ~/production.pem -t ubuntu@packages.devstructure.com "reprepro-includedeb ubuntu maverick python-cloudformation_$(VERSION)-$(BUILD)py$(PYTHON_VERSION)_all.deb"

deploy-deb-2.7:
	ssh -i ~/production.pem -t ubuntu@packages.devstructure.com "reprepro-includedeb ubuntu natty python-cloudformation_$(VERSION)-$(BUILD)py$(PYTHON_VERSION)_all.deb"

deploy-pypi:
	$(PYTHON) setup.py sdist upload

man:
	find man -name \*.ronn | xargs -n1 ronn \
		--manual="python-cloudformation" --organization=DevStructure --style=toc

gh-pages: man
	mkdir -p gh-pages
	find man -name \*.html | xargs -I__ mv __ gh-pages/
	git checkout -q gh-pages
	cp -R gh-pages/* ./
	rm -rf gh-pages
	git add .
	git commit -m "Rebuilt manual."
	git push origin gh-pages
	git checkout -q master

.PHONY: all build clean install install-lib install-man uninstall uninstall-lib uninstall-man deb deploy deploy-deb deploy-deb-2.6 deploy-deb-2.7 deploy-pypi man gh-pages
