#!/usr/bin/env python2.6
#
# Extract preloadable images from the HTML and CSS files given as the
# arguments, and emit a YAML array of unique image URLs (either absolute or
# relative, as discovered in the input files).
#
# Copyright (c) 2015 Greg Banks. All Rights Reserved.
#

import sys
import os
import re
import logging

images = set()

log = logging.getLogger(__name__)
args = sys.argv[1:]

debug = False
if len(args) > 0 and args[0] == '--debug':
    debug = True
    args.pop(0)

logging.basicConfig(level=(logging.DEBUG if debug else logging.INFO))

img_res = [
    # Captures the SRC attribute of HTML IMG tags as long
    # as the attribute is on the same line as the tag.
    re.compile(r"<img[^>]*\s+src=['\"]([^'\"]+)['\"]"),

    # Captures the url of a background image in CSS
    re.compile(r"background-image:\s*url\('([^'\"]+)'\);"),

    # Captures the gallery JS data structure in features.html
    re.compile(r"thumb:\s*['\"]([^'\"]+)['\"]"),
]

image_suffixes = set(['png', 'jpg', 'jpeg', 'gif']);

for file in args:
    if file.rpartition('.')[2].lower() in image_suffixes:
        log.debug("File \"%s\" is an image", file)
        images.add(file)
    else:
        log.debug("Reading file \"%s\"", file)
        with open(file, 'r') as fh:
            for line in fh:
                log.debug("Line: %s", line.rstrip())
                for r in img_res:
                    for image in r.findall(line):
                        log.debug("Found image %s using re %s", image, r.pattern)
                        images.add(image)

if len(images) > 0:
    print "imgpreloads: ["
    for image in sorted(images):
        print "    \"%s\"," % image
    print "]"
