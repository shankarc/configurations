#09/26/14 
# convert all your html to md
find . -name "*.ht*" | while read i; do pandoc -f html -t markdown "$i" -o "${i%.*}.md"; done

## Makefile
TXTDIR=sources
HTMLS=$(wildcard *.html)
MDS=$(patsubst %.html,$(TXTDIR)/%.markdown, $(HTMLS))

.PHONY : all

all : $(MDS)

$(TXTDIR) :
    mkdir $(TXTDIR)

$(TXTDIR)/%.markdown : %.html $(TXTDIR)
    pandoc -f html -t markdown -s $< -o $@

#!/bin/bash

# Usage: html2md /path/to/file

# Set $IFS so that filenames with spaces don't break the loop
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# Loop through path provided as argument
for x in $(find $@ -name '*.html')
do
    pandoc -f html -t markdown -o $x.md $x
done

# Restore original $IFS
IFS=$SAVEIFS
