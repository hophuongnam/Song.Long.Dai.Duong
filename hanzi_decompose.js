//Require
var hanzi = require("hanzi");
var exec = require('child_process').exec

//Initiate
var myArgs = process.argv.slice(2);
hanzi.start();

var decomposition = hanzi.decompose(myArgs[0], 2);

//console.log(decomposition.components);
process.stdout.write(decomposition.components.toString());
