# The Critter Package

## Introduction

This is a MATLAB package for iterative image reconstruction via a variety of methods. Right now it just supports SCR and STCR (via TV regularization) but in the future it should support other methods such as ESPIRiT with L1-Wavelets, multi-coil STCR and so on.

### NPM

This package uses the node package manager to manage its version control and dependencies. To use this package simply:

1. Install Node: https://nodejs.org/en/

2. Run `npm install critter` at a unix-like terminal.

This will automatically download the files for this package (and the packages it depends on) into a `node_modules` folder. If you add this folder to your MATLAB path the package `Critter` will be available.

It is crucial to note the difference in naming conventions between MATLAB and NPM. The npm package name is `critter` and the MATLAB package name is `+Critter`. If you are new to MATLAB packages please learn more about them here: http://www.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html.


### Tests

To make sure this software works as expected in the present environment, tests have been provided and can be run by executing `Critter.test`. These tests provide a very basic data-in data-out testing and it's these example data files that take up the bulk of the size of this repository.

Since all test data is stored in +tests/private, the files in this folder are not version controlled via `git update-index --assume-unchanged` as described here: http://stackoverflow.com/questions/12288212/git-update-index-assume-unchanged-on-directory.

If you want to contribute to this project please keep tests in mind and do not commit any new data without telling git to "assume-unchanged" to avoid bloating the .git file.

### Docs

In the `docs/` directory some markdown files are provided explaining how to use each of the functions and classes this package provides.
