
all: zentaworkaround KDEA.compiled ADA.compiled engine.compiled tmp/static

include /usr/share/zenta-tools/model.rules

clean:
	git clean -fdx
	rm -rf zenta-tools

tmp:
	mkdir -p tmp

pdoauth:
	scp -P 22022 -r shippable@demokracia.rulez.org:/var/www/adadocs/PDOauth/master pdoauth

tmp/static: pdoauth tmp ADA.compiled
	cp -r pdoauth/html/ pdoauth/static/ ADA engine KDEA tmp/

testenv:
	tools/testenv

zentaworkaround:
	mkdir -p ~/.zenta/.metadata/.plugins/org.eclipse.e4.workbench/
	cp workbench.xmi ~/.zenta/.metadata/.plugins/org.eclipse.e4.workbench/
	touch zentaworkaround

inputs/ADA.issues.xml:
	mkdir -p inputs
	getGithubIssues https://api.github.com label:auto_inconsistency+repo:edemo/PDOauth >inputs/ADA.issues.xml

inputs/engine.issues.xml:
	mkdir -p inputs
	getGithubIssues https://api.github.com label:auto_inconsistency+repo:edemo/PDEngine >inputs/engine.issues.xml

inputs/KDEA.issues.xml:
	mkdir -p inputs
	getGithubIssues https://api.github.com label:auto_inconsistency+repo:edemo/adadocs >inputs/KDEA.issues.xml

