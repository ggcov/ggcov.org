
# Pages which provide backwards compatibility for old URLs
PAGES=		index.html download.html screenshots.html shotdata.html \
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
BINARIES:=	$(shell m4 -I.. list-binaries.m4)	
SCRIPTS=	backbone.php

DELIVERABLES=	$(PAGES) $(IMAGES) $(BINARIES) $(SCRIPTS)

# 0=disable all counters
# 1=old broken CGI counter
# 2=experimental Backbone PHP counter
ENABLE_COUNT=	2

############################################################

all:: $(PAGES) $(SCRIPTS)

changelog.html: _changelist.html
$(PAGES): _styles.html _common.m4 _copyright.txt toc.html.in
download.html: ../version.m4 downloadables.m4
index.html: _thanks.m4

_changelist.html: ../ChangeLog changes2html
	./changes2html < $< > $@

%.html: %.html.in
	m4 $(M4FLAGS) -I.. -DHTMLFILE=$@ -DENABLE_COUNT=$(ENABLE_COUNT) $< > $@

ALPHAHOME=	/home/g/gnb
LOGAPO= 	$(ALPHAHOME)/inst/etc/log.apo
backbone.php: backbone.php.in
	m4 $(M4FLAGS) -I.. -DLOGAPO=$(LOGAPO) $< > $@

clean::
	$(RM) $(patsubst %.html.in,%.html,$(wildcard $(patsubst %.html,%.html.in,$(PAGES))))
	$(RM) _changelist.html
	$(RM) backbone.php
	
# Look for deliverables in top_srcdir and one above top_srcdir
vpath %.tar.gz ../ ../../
vpath %.rpm ../ ../../

			
############################################################

INSTALL=	install -c
htmldir=	$(HOME)/public_html/alphalink/ggcov
uploadhost=	shell.alphalink.com.au
uploaddir=	$(uploadhost):public_html

install:: installdirs $(addprefix $(htmldir)/,$(notdir $(DELIVERABLES)))

installdirs:
	@OLD=OLD`date +%Y%m%d` ;\
	if [ -d $(htmldir).$$OLD ]; then \
	    echo "/bin/rm -rf $(htmldir)" ;\
	    /bin/rm -rf $(htmldir) ;\
	else \
	    echo "/bin/mv $(htmldir) $(htmldir).$$OLD" ;\
	    /bin/mv $(htmldir) $(htmldir).$$OLD ;\
	fi
	$(INSTALL) -d $(htmldir)
	
$(htmldir)/%: %
	$(INSTALL) -m 644 $< $@

############################################################

SSH=			ssh
RSYNC_VERBOSE=		-v
#RSYNC_PATH_FLAGS=	--rsync-path=/home/g/gnb/inst/bin/rsync

upload:
	rsync $(RSYNC_VERBOSE) -r --delete -e "$(SSH)" $(RSYNC_PATH_FLAGS) $(htmldir) $(uploaddir)

# Upload via SSH-in-SSH tunnel.
upload.ocelot:
	$(MAKE) uploadhost=localhost SSH="ssh -p 1022" upload

