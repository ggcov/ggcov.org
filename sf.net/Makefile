#
# Replacement for the old ggcov.sourceforge.net website
#
PAGES=		index.html
IMAGES=		favicon.ico
OUR_CSS=	ggcov.css

############################################################

DELIVERABLES= \
	$(addprefix build/,$(PAGES) $(IMAGES) $(OUR_CSS))

all:: $(DELIVERABLES)

$(addprefix build/,$(PAGES) $(IMAGES)) : build/% : %
	@echo '    [CP] $<'
	@mkdir -p $(@D)
	@cp $< $@

$(addprefix build/,$(OUR_CSS)) : build/% : %.in
	@echo '    [M4] $<'
	@mkdir -p $(@D)
	@m4 $(M4FLAGS) $< > $@

clean::
	$(RM) -r build

############################################################

DESTINATION_install = gnb,ggcov@web.sourceforge.net:/home/project-web/ggcov/htdocs

install: all
	rsync -v -r --delete --links -e ssh build/ $(DESTINATION_$@)

