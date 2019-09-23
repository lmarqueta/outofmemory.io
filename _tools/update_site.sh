#!/bin/sh

#
# Script to update the site from github
#

_TMP=<temp dir>
_SITE=<web home>
_GIT_REPO=https://github.com/<your repo>

# *** Warning *** be careful with this command:
/bin/rm -rf $_TMP && mkdir $_TMP

# Update site
git clone $_GIT_REPO $_TMP
rsync -av --delete-after ${_TMP}/_site/ $_SITE

