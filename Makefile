UNAME_S=	    $(shell uname -s)

# relative path to release directory containing ChangeLog
CACHE_DIR=          build/cache
DEPLOY_DIR=         build/deploy
DEPLOYABLE_DIR=     build/deployable
SED_Darwin=	    sed -E
SED_Linux=	    sed -r
SED=		    $(SED_$(UNAME_S))

# Variables GGCOV_TAG and GGCOV_VERSION are cached in makefile fragment $CACHE_DIR/tag.mk
include $(CACHE_DIR)/tag.mk
GGCOV_DIR=	    $(CACHE_DIR)/ggcov-$(GGCOV_VERSION)
GGCOV_REPO_URL=     git@github.com:ggcov/ggcov.git
GGCOV_URL=          https://github.com/ggcov/ggcov/archive/$(GGCOV_TAG).tar.gz

# where to find jQuery
JQUERY_VERSION=     1.7.2
JQUERY_DIR=	    $(CACHE_DIR)/jQuery-$(JQUERY_VERSION)
JQUERY_URL=         https://ajax.googleapis.com/ajax/libs/jquery/$(JQUERY_VERSION)/jquery.min.js

# where to find the Magnific Popup extension
MAGNIFIC_VERSION=   0.9.9
MAGNIFIC_DIR=	    $(CACHE_DIR)/Magnific-Popup-$(MAGNIFIC_VERSION)
MAGNIFIC_URL=       https://github.com/dimsemenov/Magnific-Popup/archive/$(MAGNIFIC_VERSION).tar.gz

# Pages which provide backwards compatibility for old URLs
PAGES=		index.html features.html \
		compatibility.html requirements.html \
		credits.html changelog.html documents.html \
		support.html download.html
DOCS_text=	HOWTO.web
DOCS_man=	ggcov-webdb.1 ggcov.1 ggcov-run.1 git-history-coverage.1
DOCS_pdf=	docs/ggcov-osdc-200612-draft6.pdf \
		docs/ggcov-osdc-200612-paper-draft4.pdf
# Note the order of this variable defines the order
# in which the images appear in the gallery
GALLERY_IMAGES= summarywin.gif filelistwin.gif funclistwin.gif \
		callslistwin.gif callgraphwin.gif sourcewin.gif \
		callgraph2win.gif reportwin.gif legowin.gif
GALLERY_THUMBS=	$(patsubst %.gif,%_t.gif,$(GALLERY_IMAGES))
IMAGES=		$(GALLERY_IMAGES) $(GALLERY_THUMBS) \
		favicon.ico icon32.png \
		ncXL7RzcB_120x120.png \
		firefox.png utilities-terminal.png gnome-logo.png \
		logo-ubuntu_cof-white_orange-hex.png \
		download-333x333.png goto-333x333.png \
		GitHub_Logo.png GitHub-Mark-32px.png
SCRIPTS=	$(notdir $(wildcard $(MAGNIFIC_DIR)/dist/*.min.js)) \
		$(notdir $(wildcard $(JQUERY_DIR)/*.min.js)) \
		front.js
OUR_CSS=	ggcov.css
ADD_CSS=	$(notdir $(wildcard $(MAGNIFIC_DIR)/dist/*.css))

vpath %.css $(MAGNIFIC_DIR)/dist
vpath %.min.js $(MAGNIFIC_DIR)/dist
vpath %.min.js $(JQUERY_DIR)

############################################################

docdir=	$(DEPLOYABLE_DIR)/docs/$(GGCOV_VERSION)/en
DELIVERABLES= \
	$(addprefix $(DEPLOYABLE_DIR)/,$(PAGES) $(IMAGES) $(SCRIPTS) $(OUR_CSS) $(ADD_CSS) $(DOCS_pdf)) \
	$(patsubst %,$(DEPLOYABLE_DIR)/docs/$(GGCOV_VERSION)/en/%.html,$(DOCS_text) $(DOCS_man))

all:: download_assets check_js $(DELIVERABLES)

download_assets:: $(JQUERY_DIR)/.stamp $(MAGNIFIC_DIR)/.stamp $(GGCOV_DIR)/.stamp

check_js:
	@for dir in $(JQUERY_DIR) $(MAGNIFIC_DIR) ; do \
	    if [ ! -d $$dir ] ; then \
		echo "ERROR: $$dir is missing" ;\
	    fi ;\
	done

_versions_yaml= [ "0.9" ]

# Usage: $(call mustache, foo.yaml, bar.html) > baz.html
ifeq ($(UNAME_S),Darwin)

PYTHON=         python3
VENV=           build/venv
PYSTACHE=       $(VENV)/bin/pystache

download_assets:: $(PYSTACHE)

$(PYSTACHE):
	mkdir -p $(dirname $(VENV))
	$(PYTHON) -m venv $(VENV)
	$(VENV)/bin/pip install pystache PyYAML

define mustache
( $(VENV)/bin/$(basename $(PYTHON)) yaml2json.py < $(1) > $(1).json ;\
cp $(2) $(2).mustache ;\
$(PYSTACHE) $(2).mustache $(1).json ;\
$(RM) $(2).mustache $(1).json )
endef

else
define mustache
( echo "---" ; cat $(1) ; echo "---" ; cat $(2) ) | mustache
endef
endif

$(addprefix $(DEPLOYABLE_DIR)/,$(PAGES)) : $(DEPLOYABLE_DIR)/%.html : %.html head.html foot.html ggcov.css.in
	@echo '    [MUSTACHE] $<'
	@mkdir -p $(@D)
	@( \
	    echo 'versions: $(_versions_yaml)' ;\
	    ./extract-image-preloads.py $^ $(IMGPRELOADS_$*) ;\
	    sed -e '1d' -e '/^---/,$$d' < $< ;\
	) > $@.tmp.yaml
	@( \
	    cat head.html ;\
	    $(if $(PREPEND_$*),$(PREPEND_$*);) \
	    sed -e '1,/^---/d' < $< ;\
	    $(if $(APPEND_$*),$(APPEND_$*);) \
	    cat foot.html ;\
	) > $@.tmp.html
	@$(call mustache, $@.tmp.yaml, $@.tmp.html) > $@.new && mv -f $@.new $@ || (rm -f $@.new ; exit 1)
	@$(RM) $@.tmp.yaml $@.tmp.html


$(addprefix $(DEPLOYABLE_DIR)/,$(IMAGES) $(ADD_CSS) $(SCRIPTS) $(DOCS_pdf)) : $(DEPLOYABLE_DIR)/% : %
	@echo '    [CP] $<'
	@mkdir -p $(@D)
	@cp $< $@

$(addprefix $(DEPLOYABLE_DIR)/,$(OUR_CSS)) : $(DEPLOYABLE_DIR)/% : %.in
	@echo '    [M4] $<'
	@mkdir -p $(@D)
	@m4 $(M4FLAGS) $< > $@

$(patsubst %,$(docdir)/%.html,$(DOCS_text)) : $(docdir)/%.html : $(GGCOV_DIR)/doc/%
	@echo '    [TEXT2HTML] $<'
	@mkdir -p $(@D)
	@( \
	    echo 'versions: $(_versions_yaml)' ;\
	    echo "title: $(basename $(@F) .html)" ;\
	    echo 'pathup: '`echo $@ | sed -e 's|[^/][^/]*|..|g'`/ ;\
	) > $@.tmp.yaml
	@( \
	    cat head.html ;\
	    echo '<div id="columnpad" class="column">' ;\
	    markdown_py $< | \
		sed -e '/vim:/d' ;\
	    echo '</div>' ;\
	    cat foot.html ;\
	) > $@.tmp.html
	@$(call mustache, $@.tmp.yaml, $@.tmp.html) > $@.new && mv -f $@.new $@ || (rm -f $@.new ; exit 1)
	@$(RM) $@.tmp.yaml $@.tmp.html

$(patsubst %,$(docdir)/%.html,$(DOCS_man)) : $(docdir)/%.html : $(GGCOV_DIR)/doc/%
	@echo '    [MAN2HTML] $<'
	@mkdir -p $(@D)
	@( \
	    echo 'versions: $(_versions_yaml)' ;\
	    echo "title: $(basename $(@F) .html)" ;\
	    echo 'pathup: '`echo $@ | sed -e 's|[^/][^/]*|..|g'`/ ;\
	) > $@.tmp.yaml
	@( \
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
	) > $@.tmp.html
	@$(call mustache, $@.tmp.yaml, $@.tmp.html) > $@.new && mv -f $@.new $@ || (rm -f $@.new ; exit 1)
	@$(RM) $@.tmp.yaml $@.tmp.html

PREPEND_features = \
    ( \
	./mkgallery gallery_text.html $(GALLERY_IMAGES) ;\
	cat gallery.js \
    ) | ./htmlize-js.sh

PREPEND_download = ./htmlize-js.sh < download-toggle.js

APPEND_changelog =  ./changes2html.py < $(GGCOV_DIR)/ChangeLog

IMGPRELOADS_features = $(GALLERY_THUMBS)

clean::
	$(RM) -r build

############################################################
# Fetching and caching external assets

$(CACHE_DIR)/tag.mk:
	mkdir -p $(@D)
	tag=`git ls-remote --tags $(GGCOV_REPO_URL) 'GGCOV_*' | cut -d/ -f3 | sort -t_ -k2 -k3 -k4 -n | tail -1` ;\
	release=`echo "$$tag" | sed -e 's/GGCOV_//' -e 's/_/./g'` ;\
	( echo "GGCOV_TAG=$$tag" ; echo "GGCOV_VERSION=$$release" ) > $@

$(GGCOV_DIR)/.stamp:
	mkdir -p $(@D)
	curl -L -s $(GGCOV_URL) | tar -C $(@D) --strip-components 1 -xvf -
	touch $@

$(JQUERY_DIR)/.stamp:
	mkdir -p $(@D)
	curl -L -s "$(JQUERY_URL)" > $(@D)/jquery.min.js
	touch $@

$(MAGNIFIC_DIR)/.stamp:
	mkdir -p $(@D)
	curl -L -s "$(MAGNIFIC_URL)" | tar -C $(@D) --strip-components 1 -xvf -
	touch $@


############################################################

DESTINATION_rtest = $(DESTINATION_install)/test
DESTINATION_ltest = /var/www-test/ggcov

local-test: ltest
remote-test: rtest
ltest rtest: all
	rsync -v -r --delete --links --exclude=example -e ssh $(DEPLOYABLE_DIR)/ $(DESTINATION_$@)

DEPLOY_REPO_URL=       git@github.com:ggcov/ggcov.github.io.git

install:
	if [ ! -d $(DEPLOY_DIR) ] ; then \
	    mkdir -p `dirname $(DEPLOY_DIR)` ;\
	    cd `dirname $(DEPLOY_DIR)` ;\
	    git clone $(DEPLOY_REPO_URL) `basename $(DEPLOY_DIR)` ;\
	else \
	    ( \
		cd $(DEPLOY_DIR) || exit 1; \
		git checkout master ;\
		git ls-files -o -z | xargs -0 $(RM) ;\
		git fetch $(DEPLOY_REPO_URL) master ;\
		git reset --hard origin/master ;\
	    ) ;\
	fi
	rsync -vad $(DEPLOYABLE_DIR)/ $(DEPLOY_DIR)/
	( \
	    cd $(DEPLOY_DIR) || exit 1 ;\
	    git ls-files -o -z | xargs -0 git add ;\
	    git commit -a -m "Automatic commit by 'make install'" ;\
	    git push origin master ;\
	)
