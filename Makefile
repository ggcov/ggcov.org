
# relative path to release directory containing ChangeLog
RELEASEDIR=	../ggcov

# Pages which provide backwards compatibility for old URLs
PAGES=		index.html features.html requirements.html \
		compatibility.html screenshots.html shotdata.html \
		credits.html changelog.html documents.html
IMAGES=		1x1t.gif \
		callgraph2win.gif callgraph2win_t.gif callgraphwin.gif \
		callgraphwin_t.gif callslistwin.gif callslistwin_t.gif \
		filelistwin.gif filelistwin_t.gif funclistwin.gif \
		funclistwin_t.gif legowin.gif legowin_t.gif \
		reportwin.gif reportwin_t.gif \
		sourcewin.gif sourcewin_t.gif summarywin.gif \
		summarywin_t.gif favicon.ico icon32.png
CSS=		ggcov.css

DELIVERABLES=	$(PAGES) $(IMAGES) $(CSS)

############################################################

all:: $(PAGES) $(SCRIPTS) $(CSS)

changelog.html: _changelist.html
$(PAGES): _common.m4 _copyright.txt toc.html.in

_changelist.html: $(RELEASEDIR)/ChangeLog changes2html
	./changes2html < $< > $@

HTMLDEFINES=	-DHTMLFILE=$@

%.html: %.html.in
	m4 $(M4FLAGS) $(HTMLDEFINES) $< > $@

%.css: %.css.in
	m4 $(M4FLAGS) $< > $@

clean::
	$(RM) $(patsubst %.html.in,%.html,$(wildcard $(patsubst %.html,%.html.in,$(PAGES))))
	$(RM) $(patsubst %.css.in,%.css,$(wildcard $(patsubst %.css,%.css.in,$(CSS))))
	$(RM) _changelist.html

############################################################

#GGTEST=	/test/

INSTALL=	install -c
htmldir=	html-install
uploadhost=	gnb,ggcov@web.sourceforge.net
uploaddir=	$(uploadhost):htdocs/$(GGTEST)

install:: installdirs $(addprefix $(htmldir)/,$(DELIVERABLES))

installdirs:
	@OLD=OLD`date +%Y%m%d` ;\
	if [ -d $(htmldir) ] ; then \
	    if [ -d $(htmldir).$$OLD ]; then \
		echo "/bin/rm -rf $(htmldir)" ;\
		/bin/rm -rf $(htmldir) ;\
	    else \
		echo "/bin/mv $(htmldir) $(htmldir).$$OLD" ;\
		/bin/mv $(htmldir) $(htmldir).$$OLD ;\
	    fi ;\
	fi
	$(INSTALL) -m 755 -d $(htmldir)

$(htmldir)/%: %
	$(INSTALL) -m 644 $< $@

# Local test
test local-test:
	$(MAKE) htmldir=/var/www-test/ggcov install

# Remote test
remote-test:
	$(MAKE) install
	$(MAKE) GGTEST=test/ upload

############################################################

SSH=			ssh
RSYNC_VERBOSE=		-v

upload:
	rsync $(RSYNC_VERBOSE) -r --delete --links --exclude=example --exclude=docs -e "$(SSH)" $(RSYNC_PATH_FLAGS) $(htmldir)/ $(uploaddir)

