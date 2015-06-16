#!/bin/sh
# Compares head to tagged branch and produces latexdiff pdf

# Get thesis
if [ ! -d "thesis" ]; then
	git clone git@bitbucket.org:mburke/thesis.git   
	
	cd ./thesis
	# Checkout current head and compile to make figures
	git checkout HEAD
	lualatex -shell-escape thesis.tex
	bibtex thesis.aux
	bibtex apubs.aux
	lualatex -shell-escape thesis.tex
	cd ../
fi

cd ./thesis

# Checkout previva branch
git checkout v0.9

# Make pre_viva copies of all .tex files
find . -name "*.tex" -exec cp {} {}.bak \;

# Checkout current head
git checkout HEAD

# Run latexdiff on each .tex file and store result in .tex.diff
find . -name "*.tex" -exec sh -c "latexdiff {} {}.bak > {}.diff" \; 

# Cleanup all .bak files
find . -name "*.tex.bak" | xargs rm 

# Replace original .tex files with .diff ones
find . -name "*.tex.diff" -print0 | sed 's/.tex.diff//g' | xargs -0 -I namePrefix mv namePrefix.tex.diff namePrefix.tex

# Compile change pdf
lualatex -shell-escape thesis.tex
bibtex thesis.tex
lualatex -shell-escape thesis.tex

# Discard any changes (except pdf, which hopefully is untracked)
git reset --hard


 

