
all: tests tmp/enriched.xml

clean:
	git clean -fdx

tmp:
	mkdir -p tmp

tmp/enriched.xml: tmp ADA.zenta xslt/enrich.xslt
	saxon9 -s:ADA.zenta xslt/enrich.xslt >tmp/enriched.xml

tests: enrichtest

enrichtest: xslt/spec/enrich.xspec
	xspec.sh xslt/spec/enrich.xspec

