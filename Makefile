
ADADOCS=$(shell pwd)


all: zentaworkaround tests ADA.compiled ADA.checks tmp/static

include model.rules

zentaworkaround:
	mkdir -p ~/.zenta/.metadata/.plugins/org.eclipse.e4.workbench/
	cp workbench.xmi ~/.zenta/.metadata/.plugins/org.eclipse.e4.workbench/
	touch zentaworkaround

clean:
	git clean -fdx

tmp:
	mkdir -p tmp

tests: enrich.test docbook.test objlist.test

%.test: xslt/spec/%.xspec
	xspec.sh $<

pdoauth:
	scp -P 22022 -r shippable@demokracia.rulez.org:/var/www/adadocs/PDOauth/master pdoauth

tmp/static: pdoauth
	cp -r pdoauth/html/ pdoauth/static/ tmp/

ADA.checks: check.config ADA.objlist
	saxon9 -xsl:xslt/consistencycheck.xslt -s:check.config -o:ADA.checks
