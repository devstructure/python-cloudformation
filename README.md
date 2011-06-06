# python-cloudformation

## Tools for creating CloudFormation templates

`python-cloudformation` transforms Python source code representations of AWS CloudFormation templates into JSON.  It's most useful for automating tedious user data manipulation in its very rudimentary "templating language."

## Usage

See the simple example in [`python-cloudformation`(7)](http://devstructure.github.com/python-cloudformation/python-cloudformation.7.html).

## Installation

Prerequisites:

* Python >= 2.6

### From source on Mac OS X, Debian, Ubuntu, and Fedora

	git clone git://github.com/devstructure/python-cloudformation.git
	cd blueprint && make && sudo make install

### From source on CentOS and RHEL

	rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-4.noarch.rpm
	yum install python26
	git clone git://github.com/devstructure/blueprint.git
	cd blueprint && make && sudo make install PYTHON=/usr/bin/python26

This installs Python 2.6 from EPEL side-by-side with Python 2.4 and so won't break yum.

### With a package manager

DevStructure maintains Debian packages and Python eggs for Blueprint.  See [Installing with a package manager](https://github.com/devstructure/python-cloudformation/wiki/Installing-with-a-package-manager) on the wiki.

## Documentation

The [Blueprint tutorial](https://devstructure.com/docs/tutorial.html) works through creating and deploying a simple web application via Blueprint.

## Manuals

* [`python-cloudformation`(7)](http://devstructure.github.com/python-cloudformation/python-cloudformation.7.html)

## Contribute

`python-cloudformation` is [BSD-licensed](https://github.com/devstructure/python-cloudformation/blob/master/LICENSE).

* Source code: <https://github.com/devstructure/python-cloudformation>
* Issue tracker: <https://github.com/devstructure/python-cloudformation/issues>
* Documentation: <https://devstructure.com/docs/>
* Wiki: <https://github.com/devstructure/python-cloudformation/wiki>
* Mailing list: <https://groups.google.com/forum/#!forum/blueprint-users>
* IRC: `#devstructure` on Freenode
