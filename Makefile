
# relative path to release directory containing ChangeLog
RELEASEDIR=	../ggcov

# Pages which provide backwards compatibility for old URLs
PAGES=		index.html screenshots.html shotdata.html \
		changelog.html
IMAGES=		1x1t.gif \
		ggcov_banner4t.gif ggcov_banner4b.gif \
		fm-logo.gif gimp.gif valid-html40.gif \
		bchangelogd.gif bchangelog.gif \
		bdownloadd.gif bdownload.gif \
		bfeaturesd.gif bfeatures.gif \
		bscreenshotsd.gif bscreenshots.gif \
		bordert.gif borderb.gif borderl.gif borderr.gif \
		borderbl.gif borderbr.gif bordertl.gif bordertr.gif \
		borderm.gif borderitl.gif \
		cornerb.gif cornerm.gif cornert.gif \
		ribbingh.gif ribbingv.gif \
		callgraphwin.gif callgraphwin_t.gif \
		callslistwin.gif callslistwin_t.gif \
		filelistwin.gif filelistwin_t.gif \
		funclistwin.gif funclistwin_t.gif \
		sourcewin.gif sourcewin_t.gif \
		summarywin.gif summarywin_t.gif \
		callgraph2win.gif callgraph2win_t.gif

DELIVERABLES=	$(PAGES) $(IMAGES)

############################################################

all:: $(PAGES) $(SCRIPTS)

changelog.html: _changelist.html
$(PAGES): _styles.html _common.m4 _copyright.txt toc.html.in
index.html: _thanks.m4

_changelist.html: $(RELEASEDIR)/ChangeLog changes2html
	./changes2html < $< > $@

HTMLINCDIRS=	
HTMLDEFINES=	-DHTMLFILE=$@ \
		-DENABLE_COUNT=$(ENABLE_COUNT)
	
%.html: %.html.in
	m4 $(M4FLAGS) $(HTMLINCDIRS) $(HTMLDEFINES) $< > $@

clean::
	$(RM) $(patsubst %.html.in,%.html,$(wildcard $(patsubst %.html,%.html.in,$(PAGES))))
	$(RM) _changelist.html
			
############################################################

#GGTEST=	/test/

INSTALL=	install -c
htmldir=	html-install/
uploadhost=	shell.sourceforge.net
uploaddir=	$(uploadhost):/home/groups/g/gg/ggcov/htdocs$(GGTEST)

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

############################################################

SSH=			ssh
RSYNC_VERBOSE=		-v

upload: upload.$(shell uname -n | cut -d. -f1)

# Upload via SSH-in-SSH tunnel.
upload.ocelot:
	$(MAKE) uploadhost=localhost SSH="ssh -p 1022" upload.generic

# Upload via direct connection
upload.marduk: upload.generic

upload.generic:
	rsync $(RSYNC_VERBOSE) -r --delete --links -e "$(SSH)" $(RSYNC_PATH_FLAGS) $(htmldir) $(uploaddir)

