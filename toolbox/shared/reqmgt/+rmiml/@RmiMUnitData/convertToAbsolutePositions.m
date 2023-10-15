function absPositions = convertToAbsolutePositions( parseTree, rowColPositions )

arguments
    parseTree;
    rowColPositions( 1, 4 )double{ mustBeNonempty };
end


absPositions( 1 ) =  - 1;
absPositions( 2 ) =  - 1;

if isempty( parseTree ) || any( rowColPositions ==  - 1 )
    return ;
end

absPositions( 1 ) = parseTree.lc2pos( rowColPositions( 1 ), rowColPositions( 2 ) );
absPositions( 2 ) = parseTree.lc2pos( rowColPositions( 3 ), rowColPositions( 4 ) );
end
