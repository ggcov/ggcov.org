
# relative path to release directory containing ChangeLog
RELEASEDIR=	../../Software/ggcov
RELEASE=	$(shell sed -nr -e 's/^AM_INIT_AUTOMAKE\(.*, *([0-9.]+)\).*$$/\1/p' < $(RELEASEDIR)/configure.in)

# where to find jQuery
JQUERY_DIR=	../../Software/js/jQuery-1.7.2

# where to find the Magnific Popup extension
MAGNIFIC_DIR=	../../Software/js/dimsemenov-Magnific-Popup-2ff1692/dist

# Pages which provide backwards compatibility for old URLs
PAGES=		index.html features.html \
		compatibility.html requirements.html \
		credits.html changelog.html documents.html \
		support.html
DOCS_text=	HOWTO.web
DOCS_man=	ggcov-webdb.1 ggcov.1 ggcov-run.1
DOCS_pdf=	docs/ggcov-osdc-200612-draft6.pdf \
		docs/ggcov-osdc-200612-paper-draft4.pdf
# Note the order of this variable defines the order
# in which the images appear in the gallery
GALLERY_IMAGES= summarywin.gif filelistwin.gif funclistwin.gif \
		callslistwin.gif callgraphwin.gif sourcewin.gif \
		callgraph2win.gif reportwin.gif legowin.gif
IMAGES=		$(GALLERY_IMAGES) $(patsubst %.gif,%_t.gif,$(GALLERY_IMAGES)) \
		favicon.ico icon32.png \
		ncXL7RzcB_120x120.png \
		firefox.png utilities-terminal.png gnome-logo.png \
		logo-ubuntu_cof-white_orange-hex.png \
		download-333x333.png goto-333x333.png
SCRIPTS=	$(notdir $(wildcard $(MAGNIFIC_DIR)/*.min.js)) \
		$(notdir $(wildcard $(JQUERY_DIR)/*.min.js)) \
		front.js
OUR_CSS=	ggcov.css
ADD_CSS=	$(notdir $(wildcard $(MAGNIFIC_DIR)/*.css))

vpath %.css $(MAGNIFIC_DIR)
vpath %.min.js $(MAGNIFIC_DIR)
vpath %.min.js $(JQUERY_DIR)

############################################################

docdir=	build/docs/$(RELEASE)/en
DELIVERABLES= \
	$(addprefix build/,$(PAGES) $(IMAGES) $(SCRIPTS) $(OUR_CSS) $(ADD_CSS) $(DOCS_pdf)) \
	$(patsubst %,build/docs/$(RELEASE)/en/%.html,$(DOCS_text) $(DOCS_man))

all:: $(DELIVERABLES)

_versions_yaml= [ "0.9" ]

$(addprefix build/,$(PAGES)) : build/%.html : %.html head.html foot.html
	@echo '    [MUSTACHE] $<'
	@mkdir -p $(@D)
	@( \
	    sed -n -e '1p' < $< ;\
	    echo 'versions: $(_versions_yaml)' ;\
	    echo -n 'imgpreloads: ' ;\
	    ( \
		./extract-img $< ;\
		if [ -n "$(IMGPRELOADS_$*)" ]; then \
		    for f in $(IMGPRELOADS_$*) ; do \
			echo "$$f" ;\
		    done ;\
		fi \
	    ) | sort -u | ./strs-to-yaml ;\
	    sed -n -e '2,/^---/p' < $< ;\
	    cat head.html ;\
	    $(if $(PREPEND_$*),$(PREPEND_$*);) \
	    sed -e '1,/^---/d' < $< ;\
	    $(if $(APPEND_$*),$(APPEND_$*);) \
	    cat foot.html ;\
	) | mustache > $@.new && mv -f $@.new $@ || (rm -f $@.new ; exit 1)

$(addprefix build/,$(IMAGES) $(ADD_CSS) $(SCRIPTS) $(DOCS_pdf)) : build/% : %
	@echo '    [CP] $<'
	@mkdir -p $(@D)
	@cp $< $@

$(addprefix build/,$(OUR_CSS)) : build/% : %.in
	@echo '    [M4] $<'
	@mkdir -p $(@D)
	@m4 $(M4FLAGS) $< > $@

$(patsubst %,$(docdir)/%.html,$(DOCS_text)) : $(docdir)/%.html : $(RELEASEDIR)/doc/%
	@echo '    [TEXT2HTML] $<'
	@mkdir -p $(@D)
	@( \
	    echo '---' ;\
	    echo 'versions: $(_versions_yaml)' ;\
	    echo "title: $(basename $(@F) .html)" ;\
	    echo 'pathup: '`echo $@ | sed -e 's|[^/][^/]*|..|g'`/ ;\
	    echo '---' ;\
	    cat head.html ;\
	    echo '<div id="columnpad" class="column">' ;\
	    markdown_py $< | \
		sed -e '/vim:/d' ;\
	    echo '</div>' ;\
	    cat foot.html ;\
	) | mustache > $@.new && mv -f $@.new $@ || (rm -f $@.new ; exit 1)

$(patsubst %,$(docdir)/%.html,$(DOCS_man)) : $(docdir)/%.html : $(RELEASEDIR)/doc/%
	@echo '    [MAN2HTML] $<'
	@mkdir -p $(@D)
	@( \
	    echo '---' ;\
	    echo 'versions: $(_versions_yaml)' ;\
	    echo "title: $(basename $(@F) .html)" ;\
	    echo 'pathup: '`echo $@ | sed -e 's|[^/][^/]*|..|g'`/ ;\
	    echo '---' ;\
	    cat head.html ;\
	    echo '<div id="columnpad" class="column">' ;\
	    groff -man -Thtml $< | \
		sed -e '1,/<body>/d' \
		    -e '/<\/body>/,$$d' \
		    -e 's/margin-left:11%/margin-left:4em/g' \
		    -e 's/margin-left:22%/margin-left:8em/g' \
		    -e 's/<hr>//' \
		    ;\
	    echo '</div>' ;\
	    cat foot.html ;\
	) | mustache > $@.new && mv -f $@.new $@ || (rm -f $@.new ; exit 1)

PREPEND_features = \
    ( \
	./mkgallery gallery_text.html $(GALLERY_IMAGES) ;\
	cat gallery.js \
    ) | ./htmlize-js.sh

APPEND_changelog =  ./changes2html < $(RELEASEDIR)/ChangeLog

IMGPRELOADS_index = \
    goto-333x333.png \
    logo-ubuntu_cof-white_orange-hex.png \
    download-333x333.png

clean::
	$(RM) -r build

############################################################

DESTINATION_install = gnb,ggcov@web.sourceforge.net:/home/project-web/ggcov/htdocs
DESTINATION_rtest = $(DESTINATION_install)/test
DESTINATION_ltest = /var/www-test/ggcov

local-test: ltest
remote-test: rtest
install ltest rtest: all
	rsync -v -r --delete --links --exclude=example -e ssh build/ $(DESTINATION_$@)

