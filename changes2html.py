#!/usr/bin/env python
#
# Python script to convert a GNU ChangeLog into HTML for the Web page
# Because Mac awk is sooo backward
#

import sys
import os
import re

# \1=date \2=name \3@\4=email
header_re = "([A-Z][a-z][a-z] [A-Z][a-z][a-z] [ 0-9][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9] [12][0-9][0-9][0-9]) +([^<]+) +<([^@>]+)@([^@>]+)>"
in_item = False
in_list = False

def end_item():
    global in_item
    in_item = False

def end_list():
    global in_list
    end_item()
    if in_list:
        print "</ul>"
        in_list = False

def start_list():
    global in_list
    global in_item
    if not in_list:
        print "<ul>";
        in_list = True
        in_item = False

def start_item():
    global in_item
    end_item()
    start_list()
    print "<li>"
    in_item = True

def spacer():
    if in_item:
        print "<li style=\"list-style-type:none;\">&nbsp;"

def quote_meta(str):
    str = re.sub(r'&', '&amp;', str)
    str = re.sub(r'<', '&lt;', str)
    str = re.sub(r'>', '&gt;', str)
    return str

for line in sys.stdin:
    line = line.rstrip()

    m = re.match(r'^[A-Z]', line)
    if m is not None:
        # Header lines
        end_list()
        print re.sub(header_re, "<p><b>\\1 \\2</b></p>", line);
        start_list()
        continue

    m = re.match(r'^\s*$', line)
    if m is not None:
        # empty line
        spacer()
        continue

    m = re.match(r'^\s+\*\s+', line)
    if m is not None:
        # first line of record.
        start_item()
        print quote_meta(re.sub(r'^\s+\*\s+', '', line))
        continue

    # subsequent line of record
    print quote_meta(re.sub(r'^\s*', '', line))

end_list()
