
# relative path to release directory containing ChangeLog
RELEASEDIR=	../ggcov

# where to find jQuery
JQUERY_DIR=	../js/jQuery-1.7.2

# where to find the Magnific Popup extension
MAGNIFIC_DIR=	../js/dimsemenov-Magnific-Popup-2ff1692/dist

# Pages which provide backwards compatibility for old URLs
PAGES=		index.html features.html \
		compatibility.html shotdata.html \
		credits.html changelog.html documents.html
# Note the order of this variable defines the order
# in which the images appear in the gallery
GALLERY_IMAGES= summarywin.gif filelistwin.gif funclistwin.gif \
		callslistwin.gif callgraphwin.gif sourcewin.gif \
		callgraph2win.gif reportwin.gif legowin.gif
IMAGES=		$(GALLERY_IMAGES) $(patsubst %.gif,%_t.gif,$(GALLERY_IMAGES)) \
		favicon.ico icon32.png \
		stock-photo-4529201-magnifying-glass.jpg
SCRIPTS=	$(notdir $(wildcard $(MAGNIFIC_DIR)/*.min.js)) \
		$(notdir $(wildcard $(JQUERY_DIR)/*.min.js))
OUR_CSS=	ggcov.css
ADD_CSS=	$(notdir $(wildcard $(MAGNIFIC_DIR)/*.css))

vpath %.css $(MAGNIFIC_DIR)
vpath %.min.js $(MAGNIFIC_DIR)
vpath %.min.js $(JQUERY_DIR)

############################################################

all:: $(addprefix build/,$(PAGES) $(IMAGES) $(SCRIPTS) $(OUR_CSS) $(ADD_CSS))

_versions_yaml= [ "0.9" ]

$(addprefix build/,$(PAGES)) : build/%.html : %.html head.html foot.html
	@echo '    [MUSTACHE] $<'
	@mkdir -p $(@D)
	@( \
	    sed -n -e '1p' < $< ;\
	    echo 'versions: $(_versions_yaml)' ;\
	    sed -n -e '2,/^---/p' < $< ;\
	    cat head.html ;\
	    $(if $(PREPEND_$*),$(PREPEND_$*);) \
	    sed -e '1,/^---/d' < $< ;\
	    $(if $(APPEND_$*),$(APPEND_$*);) \
	    cat foot.html ;\
	) | mustache > $@.new && mv -f $@.new $@ || (rm -f $@.new ; exit 1)

$(addprefix build/,$(IMAGES) $(ADD_CSS) $(SCRIPTS)) : build/% : %
	@echo '    [CP] $<'
	@mkdir -p $(@D)
	@cp $< $@

$(addprefix build/,$(OUR_CSS)) : build/% : %.in
	@echo '    [M4] $<'
	@mkdir -p $(@D)
	@m4 $(M4FLAGS) $< > $@

PREPEND_features = \
    echo '<script type="text/javascript">' ;\
    ./mkgallery gallery_text.html $(GALLERY_IMAGES) ;\
    cat gallery.js ;\
    echo '</script>'

APPEND_changelog =  ./changes2html < $(RELEASEDIR)/ChangeLog

clean::
	$(RM) -r build

############################################################

DESTINATION_install = gnb,ggcov@web.sourceforge.net:/home/project-web/ggcov/htdocs
DESTINATION_rtest = $(DESTINATION_install)/test
DESTINATION_ltest = /var/www-test/ggcov

local-test: ltest
remote-test: rtest
install ltest rtest: all
	rsync -v -r --delete --links --exclude=example --exclude=docs -e ssh build/ $(DESTINATION_$@)

