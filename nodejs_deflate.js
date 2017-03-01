#!/usr/bin/nodejs
// Deflate an input file using raw deflate without any extra headers.
var fs = require('fs');
var zlib = require('zlib');

var inputFile = process.argv[2];
if (typeof inputFile !== 'string') {
    throw new Error('missing input file name');
}
var outputFile = process.argv[3];
if (typeof outputFile !== 'string') {
    throw new Error('missing output file name');
}

var input = fs.readFileSync(inputFile);
var output = zlib.deflateRawSync(input, {
});
console.log('deflated ' + inputFile + ' (' + input.length + ' bytes) to ' + outputFile + ' (' + output.length + ' bytes)');

fs.writeFileSync(outputFile, output);
