function [ parseTree, code ] = getParsedMTree( fileName )

arguments
    fileName string{ mustBeNonempty };
end

fileName = matlab.unittest.internal.fileResolver( fileName );

code = matlab.internal.getCode( fileName );
code = regexprep( code, '\r', '' );
parseTree = mtree( code, '-comments' );

if parseTree.isnull || parseTree.root.iskind( 'ERR' )
    parseTree = [  ];
    return ;
end
end

