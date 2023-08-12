function variables = extractVariablesFromExpression( expression )
R36
expression{ mustBeStringOrCharRow( expression ) }
end 
tree = mtree( expression );
ids = tree.mtfind( 'Kind', 'ID' );
variables = strings( ids );
variables = unique( variables );
end 


function mustBeStringOrCharRow( expression )
if ~matlab.internal.datatypes.isScalarText( expression )
error( message( 'simulinkcompiler:runtime:ExtractVariablesFromExpressionInvalidInput' ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpkmZB9D.p.
% Please follow local copyright laws when handling this file.

