#!/usr/bin/perl -wps
# bib-abbreviate: Maintain parallel bibliography abbreviation (bibstring) files
# Michael Ernst <mernst@cs.washington.edu>
# Time-stamp: <2009-12-16 10:06:28 mernst>

# Sometimes, I want a verbose bibliography; other times I want a terser
# one (usually so it doesn't take up so much space against a page limit).
# This program maintains two sets of bibliography abbreviation files, which
# lets you easily switch between the two versions.

# Invoke like:
#   bib-abbreviate bibstring-master.bib > bibstring-unabbrev.bib
#   bib-abbreviate -abbrev bibstring-master.bib > bibstring-abbrev.bib
# Then you can switch among the two versions in LaTeX by choosing between
#   \bibliography{bibstring-abbrev,inv-icse}
#   \bibliography{bibstring-unabbrev,inv-icse}

# This program converts lines like this in the bibstring-master.bib file:
#   @string{name = unabbrev = abbrev}
# into either
#   @string{name = unabbrev}
# or
#   @string{name = abbrev}
# depending on whether the "-abbrev" argument is supplied to bib-abbreviate.
#
# For example, here are some lines from my bibstring-master.bib file (which
# is also distributed with this program):
#
#   @string{ICSE99 = "Proceedings of the 21st International Conference on
#		     Software Engineering" = "ICSE"}
#   @string{ICSE99addr = "Los Angeles, CA, USA" = ""}
#   @string{ICSE99date = may # "~19--21," = may}

# I maintain my bibstring-unabbrev.bib and bibstring-abbrev.bib with a
# Makefile that contains the following entries.  The Emacs code at the end
# of bibstring-master.bib causes "make" to be run every time that the file
# is saved, so I never need to run "make" manually.
#
# all: bibstring-unabbrev.bib bibstring-abbrev.bib
#
# bibstring-unabbrev.bib: bibstring-master.bib
# 	rm -f $@
# 	bib-abbreviate $< > $@
# 	chmod -w $@
#
# bibstring-abbrev.bib: bibstring-master.bib
# 	rm -f $@
# 	bib-abbreviate -abbrev $< > $@
# 	chmod -w $@

# Another way to save space in your bibliography is to reduce the
# indentation of bibliography entries (by default, it is the width of the
# longest bibliography label) and to use a smaller font for the bibliography.
# The following TeX code does both things.
#
# %% Make bibliography items less indented, to save space; also use small font.
# \makeatletter
# \renewenvironment{thebibliography}[1]
# {\section*{\refname
#         \@mkboth{\MakeUppercase\refname}{\MakeUppercase\refname}}%
#       \vspace{5pt}
#       \begingroup
#       % \begin{footnotesize}
#       \begin{small}
#       \list{\@biblabel{\@arabic\c@enumiv}}%
#            {%\settowidth\labelwidth{\@biblabel{#1}}%
#             \settowidth\labelwidth{~}%
#             % \itemsep 0pt \parskip 0pt
#             \itemsep 0pt \parskip -2pt
#             \leftmargin\labelwidth
#             \advance\leftmargin\labelsep
#             \@openbib@code
#             \usecounter{enumiv}%
#             \let\p@enumiv\@empty
#             \renewcommand\theenumiv{\@arabic\c@enumiv}}%
#       \sloppy\clubpenalty4000\widowpenalty4000%
#       \sfcode`\.\@m}
#      {\def\@noitemerr
#        {\@latex@warning{Empty `thebibliography' environment}}%
#       \endlist
#       % \end{footnotesize}
#       \end{small}
#       \endgroup}
# \makeatother


###########################################################################

BEGIN {
  $debug = 1;
  $debug = 0;			# to debug, comment out this line
}

# "$line" is the line that has been read so far.  (??)

# Gratuitous use to avoid Perl warning.
# This variable is set by supplying "-abbrev" on the command line.
if (!defined($abbrev))
{ $abbrev = 0; }

if (defined($line) && ($_ =~ /^\@string\{/)) {
  print $line;
  $line = "";
}

if (defined($line) && (($_ =~ /^$/) || ($_ =~ /^@/))) {
  print $line;
  $line = "";
}

if (defined($line) && ($line ne "")) {
  if ($debug) {
    print "appending to: $line";
    print "appendee: $_";
  }
  $line .= $_;
  $_ = "";
} elsif (/^\@string\{/i) {
  $line = $_;
  $_ = "";
}

if ($debug && defined($line)) {
  print STDERR "line: $line";
}

if (defined($line)) {
  if ($line =~ /^\@string\{
        ([-_a-z0-9A-Z]+\s*=\s*)
        # A string without embedded quotes: \"[^\"]+\"
        # A string with embedded quotes (ignores possible errors if string
        # ends with "\\"; assume that doesn't happen):
        # An entry chunk is an abbrev or string: (?:[-_a-z0-9A-Z]+|\"(?:[^\"]|\\\")+\").
        # Permit any number of them, separated by " # ".
        ((?:[-_a-z0-9A-Z]+|\"(?:[^\"]|\\\")+\")
         (?:\s*\#\s*(?:[-_a-z0-9A-Z]+|\"(?:[^\"]|\\\")+\"))*)
        # An empty string "" is permitted in the main part of this regexp.
        (\s*=\s*
        ((?:[-_a-z0-9A-Z]+|\"(?:[^\"]|\\\")*\")
         (?:\s*\#\s*(?:[-_a-z0-9A-Z]+|\"(?:[^\"]|\\\")+\"))*)
        )?
        \s*\}\s*$/ix) {
    if ($debug) { print STDERR "match: $line"; }
    my $name = $1;
    my $long = $2;
    my $short = $4;

    if (defined($names{$name})) {
      print STDERR "WARNING: Duplicate in bibliography abbreviation file: $name\n";
    }
    $names{$name} = 1;
    if ($abbrev and defined($short)) {
      $text = $short;
    } else {
      $text = $long;
    }
    $line = "";
    print "\@string{$name$text}\n";
    $_ = "";
  } else {
    if ($debug) { print STDERR "no match: $line"; }
  }
}
