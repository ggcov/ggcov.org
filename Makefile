
# relative path to release directory containing ChangeLog
RELEASEDIR=	../ggcov

# Pages which provide backwards compatibility for old URLs
PAGES=		index.html features.html requirements.html \
		compatibility.html screenshots.html shotdata.html \
		credits.html changelog.html documents.html
IMAGES=		callgraph2win.gif callgraph2win_t.gif callgraphwin.gif \
		callgraphwin_t.gif callslistwin.gif callslistwin_t.gif \
		filelistwin.gif filelistwin_t.gif funclistwin.gif \
		funclistwin_t.gif legowin.gif legowin_t.gif \
		reportwin.gif reportwin_t.gif \
		sourcewin.gif sourcewin_t.gif summarywin.gif \
		summarywin_t.gif favicon.ico icon32.png \
		stock-photo-4529201-magnifying-glass.jpg
CSS=		ggcov.css

############################################################

all:: $(addprefix build/,$(PAGES) $(IMAGES) $(CSS))

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

$(addprefix build/,$(IMAGES)) : build/% : %
	@echo '    [CP] $<'
	@mkdir -p $(@D)
	@cp $< $@

$(addprefix build/,$(CSS)) : build/% : %.in
	@echo '    [M4] $<'
	@mkdir -p $(@D)
	@m4 $(M4FLAGS) $< > $@

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

