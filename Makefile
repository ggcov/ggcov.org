
# Pages which provide backwards compatibility for old URLs
PAGES=		index.html download.html screenshots.html shotdata.html \
		changelog.html
IMAGES=		ggcov_banner.gif ggcov_banner2.gif \
		fm.mini.jpg gimp.gif \
		valid-html40.gif \
		borderl.gif borderr.gif bordert.gif borderb.gif \
		bordertl.gif bordertr.gif borderbl.gif borderbr.gif \
		borderm.gif 1x1t.gif \
		summarywin.gif summarywin_t.gif \
		filelistwin.gif filelistwin_t.gif \
		funclistwin.gif funclistwin_t.gif \
		callslistwin.gif callslistwin_t.gif \
		callgraphwin.gif callgraphwin_t.gif \
		sourcewin.gif sourcewin_t.gif
BINARIES:=	$(shell m4 -I.. list-binaries.m4)	

DELIVERABLES=	$(PAGES) $(IMAGES) $(BINARIES)

ENABLE_COUNT=	1

############################################################

all:: $(PAGES)

changelog.html: _changelist.html
$(PAGES): _styles.html _common.m4 _copyright.html toc.html.in
download.html: ../version.m4

_changelist.html: ../ChangeLog changes2html
	./changes2html < $< > $@

%.html: %.html.in
	m4 $(M4FLAGS) -I.. -DHTMLFILE=$@ -DENABLE_COUNT=$(ENABLE_COUNT) $< > $@
	
clean::
	$(RM) $(patsubst %.html.in,%.html,$(wildcard $(patsubst %.html,%.html.in,$(PAGES))))
	$(RM) _changelist.html
	
# Look for deliverables in top_srcdir and one above top_srcdir
vpath %.tar.gz ../ ../../
vpath %.rpm ../ ../../

			
############################################################

INSTALL=	install -c
htmldir=	$(HOME)/public_html/alphalink/ggcov
uploaddir=	shell.alphalink.com.au:public_html

install:: installdirs $(addprefix $(htmldir)/,$(notdir $(DELIVERABLES)))

installdirs:
	test -d $(htmldir) || $(INSTALL) -d $(htmldir)
	
$(htmldir)/%: %
	$(INSTALL) -m 644 $< $@

############################################################

upload:
	rsync -v -r --delete -e ssh --rsync-path=/home/g/gnb/inst/bin/rsync $(htmldir) $(uploaddir)
