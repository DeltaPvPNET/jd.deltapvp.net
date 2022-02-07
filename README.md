# DeltaPvP Javadocs

This repository manages the publication of Javadoc for DeltaPvP Projects.

The current (`data`) branch holds a basic static generator and the raw javadoc data. Any new javadoc is published here.

Github Actions runs the generator (in `_generator/`) on a push to this repository, which publishes the javadocs to the `gh-pages` branch, which is visible at https://jd.deltapvp.net.
