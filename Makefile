
all: tests tmp/ADA.html tmp/static

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

pdoauth:
	scp -P 22022 -r shippable@demokracia.rulez.org:/var/www/adadocs/PDOauth/master pdoauth

tmp/static: pdoauth
	cp -r pdoauth/html/ pdoauth/static/ tmp/

