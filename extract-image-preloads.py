#!/usr/bin/env python3
#
# Extract preloadable images from the HTML and CSS files given as the
# arguments, and emit a YAML array of unique image URLs (either absolute or
# relative, as discovered in the input files).
#
# Copyright (c) 2015-2020 Greg Banks. All Rights Reserved.
#

import sys
import os
import re
import logging


log = logging.getLogger(__name__)
image_regexps = [
    # Captures the SRC attribute of HTML IMG tags as long
    # as the attribute is on the same line as the tag.
    re.compile(r"<img[^>]*\s+src=['\"]([^'\"]+)['\"]"),

    # Captures the url of a background image in CSS
    re.compile(r"background-image:\s*url\('([^'\"]+)'\);"),

    # Captures the gallery JS data structure in features.html
    re.compile(r"thumb:\s*['\"]([^'\"]+)['\"]"),
]
image_suffixes = set(['png', 'jpg', 'jpeg', 'gif']);


def extract_images(filenames):
    images = set()
    for filename in filenames:
        if filename.rpartition('.')[2].lower() in image_suffixes:
            log.debug("File \"%s\" is an image", filename)
            images.add(filename)
        else:
            log.debug("Reading file \"%s\"", filename)
            with open(filename) as fh:
                for line in fh:
                    log.debug("Line: %s", line.rstrip())
                    for r in image_regexps:
                        for image in r.findall(line):
                            log.debug("Found image %s using re %s", image, r.pattern)
                            images.add(image)
    return images


def emit_preload_list(images, fout):
    fout.write("imgpreloads: [\n")
    for image in sorted(images):
        fout.write(f"    \"{image}\",\n")
    fout.write("]\n")


def main():
    args = sys.argv[1:]
    debug = False
    if len(args) > 0 and args[0] == '--debug':
        debug = True
        args.pop(0)
    logging.basicConfig(level=(logging.DEBUG if debug else logging.INFO))
    images = extract_images(args)
    if len(images) > 0:
        emit_preload_list(images, sys.stdout)


if __name__ == "__main__":
    main()

