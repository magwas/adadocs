
ADADOCS=$(shell pwd)


all: zentaworkaround tests testmodel.compiled ADA.compiled ADA.checks tmp/static

include model.rules

zentaworkaround:
	mkdir -p ~/.zenta/.metadata/.plugins/org.eclipse.e4.workbench/
	cp workbench.xmi ~/.zenta/.metadata/.plugins/org.eclipse.e4.workbench/
	touch zentaworkaround

clean:
	git clean -fdx

tmp:
	mkdir -p tmp

tests: rich.test docbook.test objlist.test tabled.docbook.test

%.test: xslt/spec/%.xspec testmodel.%
	 saxon9 -l -xsl:xslt/tester/test.xslt -s:testmodel.$(basename $@) tests=$$(pwd)/xslt/spec/$(basename $@).xspec sources=../../testmodel.zenta,../../testmodel.rich

pdoauth:
	scp -P 22022 -r shippable@demokracia.rulez.org:/var/www/adadocs/PDOauth/master pdoauth

tmp/static: pdoauth tmp
	cp -r pdoauth/html/ pdoauth/static/ tmp/

ADA.checks: check.config ADA.objlist
	saxon9 -xsl:xslt/consistencycheck.xslt -s:check.config -o:ADA.checks

testenv:
	docker run --rm -p 5900:5900 -v $$(pwd):/adadocs -it magwas/edemotest:xslt /bin/bash
