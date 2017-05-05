proofengineering-bib:  collection of BibTeX bibliography files
===================================================

To obtain the bibliographies, run:

    git clone https://github.com/proofengineering/proofengineering-bib.git

This is a set of BibTeX bibliographies.  You can re-use them rather than
having to re-type or download.  Re-typing or downloading bibliography
entries is a notorious source of errors.  For example, even the ACM Digital
Library often has incorrect capitalization, or gives a SIGPLAN Notices
reference when the conference proceedings would be more appropriate.

Here are some other features:

 * Short and long versions of names, locations, and dates for conferences,
   journals, etc.  The short (abbreviated) version is convenient if your
   paper is nearing its page limit.  Changing between the two versions only
   requires a tiny change to your LaTeX file (see below), and no
   changes to any bib files.
 * Consistent naming convention for citation keys:  last name of first
   author, followed by last initial of each other author, followed by
   year.  This makes the citation more recognizable in your LaTeX source,
   and avoids duplicates.
 * Searchable via the bibfind tool.  For instance, `bibfind keyword1 keyword2`
   displays all the bibliographies with all the keywords, either in the
   entries in the comments.  (This is why there are no blank lines in the
   comments that abut some bib entries:  the search tool considers each
   blank line to start a new entry.  We may lift that restriction in the
   future.)

You can obtain the bibliographies by running the command
`git clone https://github.com/proofengineering/proofengineering-bib.git`
but you don't need to -- see below for how to set your build system to
automatically obtain and/or update a copy.


USAGE
-----

To choose the abbreviated (short) or unabbreviated (long) version of the
bibliography strings, use one of these commands in your LaTeX file:

    \bibliography{bibstring-abbrev,...,crossrefs-abbrev}
    \bibliography{bibstring-unabbrev,...,crossrefs}

When using the bibliographies, add near the top of your LaTeX document:

    \usepackage{url}

This defines the `\url` command used in the bibliographies.  To make URLs use
a slightly narrower font (the regular `tt` font is very wide), use:

    \usepackage{pslatex}

or, to use a smaller font, use:

    \usepackage{relsize}
    \def\UrlFont{\smaller\ttfamily}


EDITING AND ADDING ENTRIES
--------------------------

Changes, corrections, and additions are welcome.

When adding new bibliography entries, please create an entry in
`crossrefs.bib` for conferences, and create bibliography strings in
`bibstring-master` for journal/institution names and abbreviations.

For consistency, please start each new bibliography entry with "@" in the
first column, and end the entry with "}" on its own line.


SETUP -- if you use a Makefile to process your paper
----------------------------------------------------

1. Add "bib" as a dependency for the rule that calls bibtex, if any;
   for example, make "bib" a dependency for the myfile.bbl target, if any.
2. Add "bib-update" as a dependency of your default target (such as "all").
3. Add the following rules to your Makefile.

```
export BIBINPUTS ?= .:bib
bib:
ifdef PEBIB
	    ln -s ${PEBIB} $@
else
	    git clone https://github.com/proofengineering/proofengineering-bib.git $@
endif
.PHONY: bib-update
bib-update: bib
# Even if this command fails, it does not terminate the make job.
# However, to skip it, invoke make as:  make NOGIT=1 ...
ifndef NOGIT
	    -(cd bib && git pull && make)
endif
```


SETUP -- non-Makefile version
-----------------------------

If you have previously cloned proofengineering-bib and set the PEBIB environment
variable, there is nothing to do.  Otherwise, run this command:

    cd; git clone https://github.com/proofengineering/proofengineering-bib.git bib

Then, set the PEBIB environment variable to $HOME/bib and
add the "bib" directory to your BIBINPUTS environment variable.

bash syntax:

    export PEBIB=$HOME/bib
    export BIBINPUTS=.:${PEBIB}:..:


SETUP -- miscellaneous details
------------------------------

For the bibfind command, see
https://github.com/mernst/uwisdom/blob/wiki/README.adoc .
The bibfind command uses the `bibroot` file in the `proofengineering-bib` directory.

If you wish to have only a single copy of the bibliographies on your
computer, you can clone the repository just once and set the PEBIB
environment variable.  Then your Makefile will create (or you can make by
hand) a symbolic link from any directories where you are writing a paper.

Note for miktex users:
The bibtex that is supplied with miktex (the popular Windows implementation)
does not support the BIBINPUTS variable. You need to modify the miktex
configuration.  In file `...\miktex\config\miktex.ini`, edit this entry:

    Input Dirs=searchpath
    (search path for BibTeX input files -- both databases and style files).


INVOKING BIBTEX: crossref and -min-crossrefs=9999
-------------------------------------------------

proofengineering-bib's .bib files use `@crossref`.  To avoid outut like

    [1] Brun et al.  Paper title.  In [2].
    [2] Proceedings of ESEC/FSE 2011.  Szeged, Hungary, Sep. 7--9, 2011.

you need to pass the -min-crossrefs=9999 command-line option to BibTeX; for
example:

    bibtex -min-crossrefs=9999 mypaper


LICENSE
-------

Uses the Creative Commons Attribution ("CC-BY") license.  See file LICENSE.
