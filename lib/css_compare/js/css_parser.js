/**
 * @author Attila Večerek <xvecer17@stud.fit.vutbr.cz>
 */
var postcss = require('/usr/local/lib/node_modules/postcss'),
    fs = require('fs');

CssParser = {
    parse: function(src) {
        //Parses a CSS file and outputs its AST

        var code = fs.readFileSync(src, 'utf8').toString(),
            options = { from: src };

        return postcss.parse(code, options)
    }
}

var tree = CssParser.parse(process.argv[2]);

console.log(JSON.stringify(tree, null, 2));