function [ P, T ] = makeTetrahedra( p, t, h, h0 )

arguments
    p{ mustBeNumeric, mustBeNx2 }
    t{ mustBeNumeric, mustBeNx3 }
    h{ mustBeNumeric }
    h0{ mustBeNumeric } = 0
end


if ( h <= h0 )
    error( message( 'MATLAB:polyfun:TetMaxLessThanMin' ) );
end

pbottom = p;
pbottom( :, 3 ) = h0;
tbottom = t;
ptop = p;
ptop( :, 3 ) = h;
ttop = tbottom + max( size( p ) );
tprism = [ tbottom, ttop ];
pprism = [ pbottom;ptop ];


mask = [ 1, 2, 3, 4, 5, 6;2, 3, 1, 5, 6, 4;3, 1, 2, 6, 4, 5;4, 6, 5, 1, 3, 2;5, 4, 6, 2, 1, 3;6, 5, 4, 3, 2, 1 ];
T = [  ];
for i = 1:size( tprism, 1 )
    prism_vals = tprism( i, : );
    [ ~, minVertex ] = min( prism_vals );
    indirectionVec = mask( minVertex, : );
    rotatedPrism = prism_vals( indirectionVec );
    refTet1 = [ 1, 2, 3, 6;1, 2, 6, 5;1, 5, 6, 4 ];
    refTet2 = [ 1, 2, 3, 5;1, 5, 3, 6;1, 5, 6, 4 ];


    if min( rotatedPrism( 2 ), rotatedPrism( 6 ) ) < min( rotatedPrism( 3 ), rotatedPrism( 5 ) )
        T = [ T;rotatedPrism( refTet1 ) ];
    else

        T = [ T;rotatedPrism( refTet2 ) ];
    end

end


P = pprism;

end

function mustBeNx2( A )
if ( size( A, 2 ) ~= 2 )
    error( message( 'MATLAB:polyshape:notNx2Error' ) );
end
end

function mustBeNx3( A )
if ( size( A, 2 ) ~= 3 )
    error( message( 'MATLAB:polyfun:stlInvalidTri' ) );
end
end

