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
	find cloudformation -type d -printf %P\\0 | xargs -0r -I__ install -d $(DESTDIR)$(pydir)/cloudformation/__
	find cloudformation -type f -name \*.py -printf %P\\0 | xargs -0r -I__ install -m644 cloudformation/__ $(DESTDIR)$(pydir)/cloudformation/__
	PYTHONPATH=$(DESTDIR)$(pydir) $(PYTHON) -mcompileall $(DESTDIR)$(pydir)/cloudformation

install-man:
	find man -type d -printf %P\\0 | xargs -0r -I__ install -d $(DESTDIR)$(mandir)/__
	find man -type f -name \*.[12345678].gz -printf %P\\0 | xargs -0r -I__ install -m644 man/__ $(DESTDIR)$(mandir)/__

uninstall: uninstall-lib uninstall-man

uninstall-lib:
	find cloudformation -type f -name \*.py -printf %P\\0 | xargs -0r -I__ rm -f $(DESTDIR)$(pydir)/cloudformation/__ $(DESTDIR)$(pydir)/cloudformation/__c
	find cloudformation -depth -mindepth 1 -type d -printf %P\\0 | xargs -0r -I__ rmdir $(DESTDIR)$(pydir)/cloudformation/__ || true
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(pydir)/cloudformation || true

uninstall-man:
	find man -type f -name \*.[12345678].gz -printf %P\\0 | xargs -0r -I__ rm -f $(DESTDIR)$(mandir)/__
	find man -depth -mindepth 1 -type d -printf %P\\0 | xargs -0r -I__ rmdir $(DESTDIR)$(mandir)/__ || true
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(mandir) || true

build: build-deb build-pypi

build-deb:
	make install prefix=/usr DESTDIR=debian
	fpm -s dir -t deb -C debian \
		-n python-cloudformation -v $(VERSION)-$(BUILD)py$(PYTHON_VERSION) -a all \
		-d python$(PYTHON_VERSION) \
		-m "Richard Crowley <richard@devstructure.com>" \
		--url "https://github.com/devstructure/python-cloudformation" \
		--description "Tools for creating CloudFormation templates."
	make uninstall prefix=/usr DESTDIR=debian

build-pypi:
	m4 -D__VERSION__=$(VERSION) setup.py.m4 >setup.py
	$(PYTHON) setup.py bdist_egg

deploy: deploy-deb deploy-pypi

deploy-deb:
	scp -i ~/production.pem python-cloudformation_$(VERSION)-$(BUILD)py$(PYTHON_VERSION)_all.deb ubuntu@packages.devstructure.com:
	make deploy-deb-$(PYTHON_VERSION)
	ssh -i ~/production.pem -t ubuntu@packages.devstructure.com "rm python-cloudformation_$(VERSION)-$(BUILD)py$(PYTHON_VERSION)_all.deb"

deploy-deb-2.6:
	ssh -i ~/production.pem -t ubuntu@packages.devstructure.com "sudo freight add python-cloudformation_$(VERSION)-$(BUILD)py$(PYTHON_VERSION)_all.deb apt/lenny apt/squeeze apt/lucid apt/maverick"
	ssh -i ~/production.pem -t ubuntu@packages.devstructure.com "sudo freight cache apt/lenny apt/squeeze apt/lucid apt/maverick"

deploy-deb-2.7:
	ssh -i ~/production.pem -t ubuntu@packages.devstructure.com "sudo freight add python-cloudformation_$(VERSION)-$(BUILD)py$(PYTHON_VERSION)_all.deb apt/natty"
	ssh -i ~/production.pem -t ubuntu@packages.devstructure.com "sudo freight cache apt/natty"

deploy-pypi:
	$(PYTHON) setup.py sdist upload

man:
	find man -name \*.ronn | xargs -n1 ronn \
		--manual="python-cloudformation" --organization=DevStructure --style=toc
	find man -name \*.[12345678] | xargs gzip

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
