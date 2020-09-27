#!/bin/sh

wget --mirror --no-parent --no-cookies --level=1 -nH --cut-dirs=4 \
  https://aeronav.faa.gov/content/aeronav/sectional_files/PDFs/
