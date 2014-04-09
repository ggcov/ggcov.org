#!/bin/bash
#
# Given a JS script on stdin, emit an HTML-ized inline script tag
# containing the JS suitably escaped to keep the W3C validator happy.
#

echo '<script type="text/javascript">'
echo '//<![CDATA['

#
# HTML parses end tags in a CDATA but not begin tags
# so we need to escape any end tags we find, using a
# spurious backslash, assuming they're inside a JS
# string literal.  So </foo> becomes <\/foo> which
# is still the same JS string literal but not visible
# to HTML.  See
#
# http://www.htmlhelp.com/tools/validator/problems.html#script
#
sed -e 's|</\([a-zA-Z][a-zA-Z0-9]*\)>|<\\/\1>|g'

echo '//]]>'
echo '</script>'
