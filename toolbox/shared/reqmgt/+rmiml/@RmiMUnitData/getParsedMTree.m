function [ parseTree, code ] = getParsedMTree( fileName )






R36
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



% Decoded using De-pcode utility v1.2 from file /tmp/tmpNE9myQ.p.
% Please follow local copyright laws when handling this file.

