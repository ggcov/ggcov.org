
# whether release is from maintenance or development branch
ifeq ($(RELEASE),maint)
  # maintenance release
else
  ifeq ($(RELEASE),dev)
    # development release
  else
    # none of the above
    _discard:=$(error Please set the RELEASE environment variable to either `maint' or `dev')
  endif
endif

# relative path to release directory containing tarballs, changelog etc
RELEASEDIR=	../ggcov-$(RELEASE)

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
BINARIES:=	$(addprefix $(RELEASEDIR)/,$(shell m4 -I$(RELEASEDIR) list-binaries.m4))
SCRIPTS=	backbone.php
DOTFILES=	.htaccess downloads/.htaccess

DELIVERABLES=	$(PAGES) $(IMAGES) $(SCRIPTS) $(DOTFILES) \
		$(addprefix downloads/,$(notdir $(BINARIES)))

# 0=disable all counters
# 1=old broken CGI counter
# 2=experimental Backbone PHP counter
ENABLE_COUNT=	2

############################################################

all:: $(PAGES) $(SCRIPTS)

changelog.html: _changelist.html
$(PAGES): _styles.html _common.m4 _copyright.txt toc.html.in
download.html: $(RELEASEDIR)/version.m4 downloadables.m4
index.html: _thanks.m4

_changelist.html: $(RELEASEDIR)/ChangeLog changes2html
	./changes2html < $< > $@

HTMLINCDIRS=	-I$(RELEASEDIR)
HTMLDEFINES=	-DHTMLFILE=$@ \
		-DENABLE_COUNT=$(ENABLE_COUNT) \
		-DRELEASEDIR=$(RELEASEDIR)
	
%.html: %.html.in
	m4 $(M4FLAGS) $(HTMLINCDIRS) $(HTMLDEFINES) $< > $@

ALPHAHOME=	/home/g/gnb
LOGAPO= 	$(ALPHAHOME)/inst/etc/log.apo
backbone.php: backbone.php.in
	m4 $(M4FLAGS) -I$(RELEASEDIR) -DLOGAPO=$(LOGAPO) $< > $@

clean::
	$(RM) $(patsubst %.html.in,%.html,$(wildcard $(patsubst %.html,%.html.in,$(PAGES))))
	$(RM) _changelist.html
	$(RM) backbone.php
			
############################################################

INSTALL=	install -c
htmldir=	$(HOME)/public_html/alphalink/ggcov
uploadhost=	shell.alphalink.com.au
uploaddir=	$(uploadhost):public_html

install:: installdirs $(addprefix $(htmldir)/,$(DELIVERABLES))

installdirs:
	@OLD=OLD`date +%Y%m%d` ;\
	if [ -d $(htmldir).$$OLD ]; then \
	    echo "/bin/rm -rf $(htmldir)" ;\
	    /bin/rm -rf $(htmldir) ;\
	else \
	    echo "/bin/mv $(htmldir) $(htmldir).$$OLD" ;\
	    /bin/mv $(htmldir) $(htmldir).$$OLD ;\
	fi
	$(INSTALL) -m 755 -d $(htmldir)
	$(INSTALL) -m 755 -d $(htmldir)/downloads
	
$(htmldir)/%: %
	$(INSTALL) -m 644 $< $@

$(htmldir)/.%: %
	$(INSTALL) -m 644 $< $@

$(htmldir)/downloads/%: $(RELEASEDIR)/%
	$(INSTALL) -m 644 $< $@
	ln -sf backbone.php $(htmldir)/$*

$(htmldir)/downloads/.%: downloads/%
	$(INSTALL) -m 644 $< $@

############################################################

SSH=			ssh
RSYNC_VERBOSE=		-v
#RSYNC_PATH_FLAGS=	--rsync-path=/home/g/gnb/inst/bin/rsync

upload: upload.$(shell uname -n | cut -d. -f1)

# Upload via SSH-in-SSH tunnel.
upload.ocelot:
	$(MAKE) uploadhost=localhost SSH="ssh -p 1022" upload.generic

# Upload via direct connection
upload.marduk: upload.generic

upload.generic:
	rsync $(RSYNC_VERBOSE) -r --delete -e "$(SSH)" $(RSYNC_PATH_FLAGS) $(htmldir) $(uploaddir)

