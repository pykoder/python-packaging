include meta.make

###############################################################################

all: $(NAME).html $(NAME).pdf

.PHONY : all html pdf odt pdf-latex slides jdhp publish clean init

SRCFILES=Makefile main.rst content/*.rst

## ARTICLE ####################################################################

# HTML ############

html: $(NAME).html

$(NAME).html: $(SRCFILES)
	rst2html --title=$(TITLE) --date --time --generator \
		--language=$(LANGUAGE) --tab-width=4 --math-output=$(MATH_OUTPUT) \
		--source-url=$(SOURCE_URL) --stylesheet=$(HTML_STYLESHEET) \
		--section-numbering --embed-stylesheet --strip-comments \
		main.rst $@

# PDF #############

pdf: $(NAME).pdf

$(NAME).pdf: $(SRCFILES)
	rst2pdf --language=$(LANGUAGE) --repeat-table-rows -o $@ main.rst

# ODT #############

odt: $(NAME).odt

$(NAME).odt: $(SRCFILES)
	rst2odt main.rst $@

# PDF Latex #######

pdf-latex: $(NAME).latex.pdf

$(NAME).latex.pdf: $(SRCFILES)
	#pandoc --toc -N  -V papersize:"a4paper" -V geometry:"top=2cm, bottom=3cm, left=2cm, right=2cm" -V "fontsize:12pt" -o $@ main.rst
	pandoc --toc -N  -V papersize:"a4paper" -V "fontsize:12pt" -o $@ main.rst

## SLIDES #####################################################################

slides: $(NAME)_slides.html

$(NAME)_slides.html: $(SRCFILES)
	rst2s5 --title=$(TITLE) --date --time --generator \
		--language=$(LANGUAGE) --tab-width=4 --math-output=$(MATH_OUTPUT) \
		--source-url=$(SOURCE_URL) \
		main.rst $@

## JDHP #######################################################################

publish: jdhp

jdhp:$(NAME).pdf $(NAME).html
	# JDHP_DOCS_URI is a shell environment variable that contains the
	# destination URI of the HTML files.
	@if test -z $$JDHP_DOCS_URI ; then exit 1 ; fi

	# Copy HTML
	@rm -rf $(HTML_TMP_DIR)/
	@mkdir $(HTML_TMP_DIR)/
	cp -v $(NAME).html $(HTML_TMP_DIR)/
	cp -vr images $(HTML_TMP_DIR)/

	# Upload the HTML files
	rsync -r -v -e ssh $(HTML_TMP_DIR)/ ${JDHP_DOCS_URI}/$(NAME)/
	
	# JDHP_DL_URI is a shell environment variable that contains the destination
	# URI of the PDF files.
	@if test -z $$JDHP_DL_URI ; then exit 1 ; fi
	
	# Upload the PDF file
	rsync -v -e ssh $(NAME).pdf ${JDHP_DL_URI}/pdf/

## CLEAN ######################################################################

clean:
	@echo "Remove compilation files"
	@rm -rvf ui/

init: clean
	@echo "Remove target files"
	@rm -vf $(NAME).html
	@rm -vf $(NAME).pdf
	@rm -vf $(NAME).latex.pdf
	@rm -vf $(NAME).odt
	@rm -vf $(NAME).latex
	@rm -vf $(NAME)_slides.html
	@rm -rf $(HTML_TMP_DIR)/

