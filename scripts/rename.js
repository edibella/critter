// Pull in file system utilities
fs = require('fs');

// Specify npm name and Matlab Package name
NPM_NAME = 'critter';
MATLAB_NAME = '+Critter';

// Rename package so that MATLAB can use it.
npmPath = "../" + NPM_NAME;
newPath = "../" + MATLAB_NAME;
fs.renameSync(npmPath, newPath);
