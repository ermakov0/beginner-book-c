DPI = 600

#project=''

SVG := $(shell find images -type f -name '*.svg')
DIA := $(shell find images -type f -name '*.dia')
SOURCES := $(shell find examples -type f -name '*.c')

SVG2PNG := $(SVG:images/%.svg=images-gen/svg_%.png)
DIA2PNG := $(DIA:images/%.dia=images-gen/dia_%.png)

#all: myc.pdf

myc.pdf: myc.tex $(SVG2PNG) $(DIA2PNG)
	pdflatex myc.tex
	pdflatex myc.tex
	cp $@ $(shell date +%Y%m%d)_$@

book: myc.pdf
	pdfbook --short-edge $<
	cp myc-book.pdf $(shell date +%Y%m%d)_myc-book.pdf

zip: myc.pdf $(SOURCES)
	zip myc.zip $<

test: $(SOURCES:%.c=%_gcc) $(SOURCES:%.c=%_clang)

# -save-temps -Wimplicit-fallthrough
examples/%_gcc: examples/%.c
	gcc -std=c99 -Wall -Wextra $< -o $@

examples/%_clang: examples/%.c
	clang -std=c99 -Wall -Wextra $< -o $@

images-gen/dia_%.eps: images/%.dia
	dia $< -e $@

images-gen/svg_%.png: images/%.svg
	convert -density $(DPI) -monochrome $< $@

images-gen/dia_%.png: images-gen/dia_%.eps
	convert -density $(DPI) -monochrome $< $@

clean:
	rm -f *.aux *.log *.nav *.snm *.toc *.vrb *.out
	rm -f *.ilg *.ind *.idx
	rm -f *.i *.s *.o *.bc
	find images-gen -type f -not -name '.placeholder' -exec rm {} \;
	find examples -type f -not -name '*.c' -exec rm {} \;
