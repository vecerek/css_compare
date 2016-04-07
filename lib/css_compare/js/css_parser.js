/**
 * @author Attila Večerek <xvecer17@stud.fit.vutbr.cz>
 */
var css = require('/usr/local/lib/node_modules/css'),
    fs = require('fs');

CssParser = {
    parse: function(src, isStdin) {
        //Parses a CSS file and outputs its AST

        var code = src,
            options = {};

        if(!isStdin) {
            code = fs.readFileSync(src, 'utf8').toString();
        }

        return css.parse(code, options)
    }
}

var tree;

if (process.argv[2] === "-stdin") {
    tree = CssParser.parse(process.argv[3], true);
} else {
    tree = CssParser.parse(process.argv[2]);
}

console.log(JSON.stringify(tree, null, 2));