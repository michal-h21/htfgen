htfgen 
------

This is a set of tools to simplify creation of `htf` fonts for `tex4ht`.

## Installation

    cd `kpsewhich -var-value TEXMFHOME`
    mkdir -p tex/latex
    cd tex/latex
    git clone https://github.com/michal-h21/htfgen.git
    cd htfgen
    tex makeenc.tex
    chmod +x lsenc
    chmod +x tfmtochars
    chmod +x htfgen
    ls -s /full/path/to/thisdir/lsenc /usr/local/bin/lsenc
    ls -s /full/path/to/thisdir/tfmtochars /usr/local/bin/tfmtochars
    ls -s /full/path/to/thisdir/htfgen /usr/local/bin/htfgen

## Usage

List font with `lsenc`


