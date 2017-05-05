# Put user-specific changes in your own Makefile.user.
# Make will silently continue if that file does not exist.
-include Makefile.user

BIB_ABBREVIATE ?= ./bib-abbreviate.pl

# TODO: reinstate bibstring-crossrefs-abbrev.bib
all: bibstring-unabbrev.bib bibstring-abbrev.bib bibroot docs/index.html

BIBFILES := $(shell ls *.bib | grep -v bibstring-unabbrev.bib | grep -v bibstring-abbrev.bib)

clean: bibtest-aux-clean
	rm -f bibstring-unabbrev.bib bibstring-abbrev.bib bibroot bibtest.tex

docs/index.html: README
	asciidoctor $< --out-file=$@

bibstring-unabbrev.bib: bibstring-master.bib $(BIB_ABBREVIATE)
	@rm -f $@
	$(BIB_ABBREVIATE) $< > $@
	@chmod -w $@

bibstring-abbrev.bib: bibstring-master.bib $(BIB_ABBREVIATE)
	@rm -f $@
	$(BIB_ABBREVIATE) -abbrev $< > $@
	@chmod -w $@

## TODO: write a new abbreviaton script, only for [book]titles
# bibstring-crossrefs-abbrev.bib: bibstring-crossrefs-master.bib $(BIB_ABBREVIATE)
# 	@rm -f $@
# 	$(BIB_TITLE_ABBREVIATE) -abbrev $< > $@
# 	@chmod -w $@

bibroot: *.bib
	@rm -f $@
	@ls -1 *.bib | perl -p -e 'BEGIN { print "% File for finding bibliography items.\n\n"; } if (/^bibstring/ || /^crossrefs/) { $$_=""; next; }; s:^(.*)$$:\\include{$$1}:;' > $@
	@chmod -w $@

bibtest-aux-clean:
	rm -f bibtest.aux bibtest.bbl bibtest.blg bibtest.dvi bibtest.log

bibtest.tex: *.bib
	@rm -f $@
	@ls -1 *.bib | perl -p -e 'BEGIN { print "\\documentclass{report}\n\\usepackage{url}\n\\usepackage{fullpage}\n\\usepackage{relsize}\n\\begin{document}\\hbadness=10000\n\n\\bibliographystyle{alpha}\n\\nocite{*}\n\n\\bibliography{bibstring-unabbrev"; } END { print ",crossrefs}\n\n\\end{document}\n"; } if (/^bibstring/ || /^crossrefs/) { $$_=""; next; }; s:^(.*)\.bib\n:,$$1:;' > $@
	@chmod -w $@
# This must be phony because a file might be old, but not listed in bibroot.
.PHONY: bibtest.tex

# Before doing this, run bibtex-validate-globally
# I'm not sure why this doesn't work (so for now do it by hand):
#   emacs -batch -l bibtex --eval="(progn (setq bibtex-files '(bibtex-file-path) enable-local-eval t) (bibtex-validate-globally))"
test: bibtest
bibtest: all bibtest-aux-clean bibtest.tex
	@echo -n 'First latex run, suppressing warnings...'
	@-latex -interaction=batchmode bibtest >/dev/null 2>&1
	@echo 'done'
	bibtex -terse -min-crossrefs=9999 bibtest 2>&1 | grep -v "Warning--to sort, need editor, organization"
	@echo -n 'Second latex run, suppressing warnings...'
	@-latex -interaction=batchmode bibtest >/dev/null 2>&1
	@echo 'done'
	@echo 'Third latex run, now warnings matter:'
	latex -interaction=batchmode bibtest
# This doesn't work.  I don't want non-ASCII characters within used fields of
# bib entries, but elsewhere in the file, and in the authorASCII field, is OK.
# chartest:
# 	grep -P "[\x80-\xFF]" *.bib

PUBS_SRC ?= /afs/csail.mit.edu/group/pag/www/pubs-src

# Make a version of the bibliography web pages, based on your working copy,
# in the subdirectory webtest. If it looks good, you can regenerate the
# real version by doing a "make" in $pag/www/pubs, or wait for an automatic
# update that currently happens once a month.
# You must have the Daikon scripts directory in your path, to find the
# html-update-toc command.
webtest: all
	mkdir -p webtest
	rsync -rC $(PUBS_SRC)/ webtest
	$(MAKE) -C webtest -f $(PUBS_SRC)/Makefile-pubs BIBDIR=`pwd`

tags: TAGS

TAGS: ${BIBFILES}
	etags ${BIBFILES}

showvars:
	@echo "BIBFILES = ${BIBFILES}"
