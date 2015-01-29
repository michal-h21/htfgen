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

First, we need to figure out, whether tested font is virtual. Virtual fonts aren't supported at the moment. 

    lsenc fontname

for `tfm` font, we get something like:

    $ lsenc eccc1000
    eccc1000        tfm     EXTENDED TEX FONT ENCODING - LATIN

for virtual font, the outpus is like this:

    $ lsenc ntxmia 
    ntxmia	vf	FONTSPECIFIC
      txmia	tfm	FONTSPECIFIC
      txsyc	tfm	FONTSPECIFIC
      txr	vf	TEX TEXT
        rtxptmr	tfm	TEXBASE1ENCODING
        rtxr	tfm	FONTSPECIFIC
      ntxexb	tfm	UNSPECIFIED
      rtxmio	tfm	FONTSPECIFIC
      zxlr-8r	tfm	TEXBASE1ENCODING
      ptmr8r	tfm	TEXBASE1ENCODING
      zxxrl7z	tfm	ADOBESTANDARDENCODING
    
first entry on each line is a font name, second font type and third is font 
encoding. Font encoding information provided by fonts is unreliable!

If font type is `tfm`, we can process to another step, which is translation of
8-bit characters to unicode characters using glyph info encoded in `enc` or 
`afm` files.

`tfmtochars` script is used to generate `tsv` file with char number, glyph name
and hex unicode value.

    $ tfmtochars fontname [enc]

`tfmtochars` tries to find `enc` file in `map` files provided by `pdftex`, you
need to provide the name only in the case the `enc` file is not configured for
given font.

    $ tfmtochars eccc1000
    0	grave	0060
    1	acute	00B4
    2	circumflex	02C6
    ...
    253	yacute	00FD
    254	thorn	00FE
    255	germandbls	00DF

for some fonts, `enc` file can't be found:

    $ tfmtochars zxxrl7z
    Cannot load enc file for txmia

You may try to find a enc file by hand (Google?). Common `enc` names can be 
found in [fontname guide](http://ftp.math.utah.edu/pub/tex/historic/fonts/fontname/fontname-2.2/fontname_5.html#SEC22). 

From `lsenc zxxrl7z` we know that this font uses `ADOBESTANDARDENCODING`, which is coded as `8a`:

    $ tfmtochars zxxrl7z 8a 

we should control, whether the output is correct (`nil` values instead 
of hexadecimal codes are suspicious). We may use 

    $ tfmtochars zxxrl7z 8a | grep nil

to test that. If the output is correct, we need to save the output to the 
`tsv` file, with command:


    $ tfmtochars zxxrl7z 8a > zxxrl7z.zsv

now we can generate the `htf` file with `htfgen`

    $ htfgen zxxrl7z.tsv > zxxrl7z.htf

To test the `htf` file, you can use file `htffonttest.tex` distributed with 
`htfgen`. Copy it to your working directory and add font name after 
`\font\x=...`:

    \font\x= zxxrl7z

compile this file with both `pdflatex` and `htlatex` (with unicode on, ie:

    htlatex htffonttest "xhtml,charset=utf-8" " -cunihtf -utf8"

and compare the resulting `pdf` and `html` files.


## Issues

### math fonts are mess

Math fonts with calligraphic features such as fraktur or scripts doesn't 
reflect these styles in glyph names, so it is impossible to automatically 
reflect these features. See [unicode math symbols](http://milde.users.sourceforge.net/LUCR/Math/unimathsymbols.xhtml)
for unicode values of these features. You may need to correct unicode hex codes
in the `tsv` file by hand. Any ideas how to solve that automatically will be
really appreciated.

### parse afm files when no enc is found

We may parse afm files for glyph names, when no encoding is found or provided.
Not all fonts does have `afm` files, though.

### virtual fonts

My idea is following: 

- first we need to make `tsv` files for all referenced fonts
- then make new `tsv` with referenced characters from particular `tsv` files
- sometimes character in the virtual font is composed from more characters from
one or more referenced fonts. It is unlikely that this can be solved 
automatically

### Some symbols in TeX fonts doesn't have unicode characters


