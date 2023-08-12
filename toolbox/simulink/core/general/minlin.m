function [ ma, mb, mc, keepList ] = minlin( A, B, C )





















[ nx, nu ] = size( B );
keepList = find( any( logical( B ), 2 ) );

removeList = ( 1:nx )';
removeList( keepList ) = [  ];
newKeepList = keepList;
while ~isempty( newKeepList )




newKeepList = removeList( find( any( logical( A( removeList, keepList ) ), 2 ) ) );
keepList = [ keepList;newKeepList ];
removeList = ( 1:nx )';
removeList( keepList ) = [  ];
end 


keepList = sort( keepList );
A = A( keepList, keepList );
B = B( keepList, : );
C = C( :, keepList );
[ nx, nu ] = size( B );


keepList = find( any( logical( C ), 1 ) )';
removeList = ( 1:nx )';
removeList( keepList ) = [  ];
newKeepList = keepList;
while ~isempty( newKeepList )





newKeepList = removeList( find( any( logical( A( keepList, removeList ) ), 1 ) ) );
keepList = [ keepList;newKeepList ];

removeList = ( 1:nx )';
removeList( keepList ) = [  ];
end 


keepList = sort( keepList );
ma = A( keepList, keepList );
mb = B( keepList, : );
mc = C( :, keepList );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpGeQcbz.p.
% Please follow local copyright laws when handling this file.

