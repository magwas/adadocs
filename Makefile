
all: tests tmp/ADA.html

clean:
	git clean -fdx

tmp:
	mkdir -p tmp

tests: enrichtest docbooktest

enrichtest: xslt/spec/enrich.xspec
	xspec.sh xslt/spec/enrich.xspec

docbooktest: xslt/spec/docbook.xspec
	xspec.sh xslt/spec/docbook.xspec

tmp/pics:
	mkdir -p tmp/pics

pics: tmp/pics
	/opt/Zenta/Zenta -load $$(pwd)/ADA.zenta -targetdir $$(pwd)/tmp -runstyle $$(pwd)/diagrams.style -exit

tmp/ADA.rich: tmp xslt/enrich.xslt ADA.zenta
	saxon9 -xsl:xslt/enrich.xslt -s:ADA.zenta -im:enrich >tmp/ADA.rich

tmp/ADA.docbook: tmp tmp/ADA.rich xslt/docbook.xslt
	saxon9 -xsl:xslt/docbook.xslt -s:tmp/ADA.rich >tmp/ADA.docbook

tmp/ADA.html: tmp tmp/ADA.docbook pics tmp/structured.css
	saxon9 -xsl:xslt/docbook2html.xslt -s:tmp/ADA.docbook >tmp/ADA.html

tmp/structured.css: tmp static/structured.css
	cp static/* tmp/
