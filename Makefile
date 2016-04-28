
all: zentaworkaround ADA.compiled tmp/static

include $(ZENTATOOLS)/model.rules

clean:
	git clean -fdx
	rm -rf zenta-tools

tmp:
	mkdir -p tmp

pdoauth:
	scp -P 22022 -r shippable@demokracia.rulez.org:/var/www/adadocs/PDOauth/master pdoauth

tmp/static: pdoauth tmp
	cp -r pdoauth/html/ pdoauth/static/ tmp/

testenv:
	docker run --rm -p 5900:5900 -v $$(pwd):/adadocs -it magwas/edemotest:xslt /bin/bash

zentaworkaround:
	mkdir -p ~/.zenta/.metadata/.plugins/org.eclipse.e4.workbench/
	cp workbench.xmi ~/.zenta/.metadata/.plugins/org.eclipse.e4.workbench/
	touch zentaworkaround

