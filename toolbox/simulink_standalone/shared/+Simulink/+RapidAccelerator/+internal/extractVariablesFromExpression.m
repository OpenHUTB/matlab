function variables = extractVariablesFromExpression( expression )
arguments
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

