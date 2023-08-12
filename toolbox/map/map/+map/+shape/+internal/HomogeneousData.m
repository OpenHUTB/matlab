classdef HomogeneousData < map.shape.internal.Data








properties 
NumVertices uint32 = 0
VertexCoordinate1( 1, : )double = [  ]
VertexCoordinate2( 1, : )double = [  ]
end 


methods 
function tf = ismultipoint( data )

tf = false( size( data.NumVertices ) );
end 


function tf = isHomogeneous( ~ )
tf = true;
end 


function tf = isemptyArray( data )
R36
data( 1, 1 )map.shape.internal.Data
end 
tf = isempty( data.NumVertices );
end 


function len = arrayLength( data )
R36
data( 1, 1 )map.shape.internal.Data
end 
len = length( data.NumVertices );
end 


function sz = arraySize( data, args )
R36
data( 1, 1 )map.shape.internal.Data
args( 1, : )cell
end 
sz = size( data.NumVertices, args{ : } );
end 


function tf = hasNoCoordinateData( data )
tf = ( data.NumVertices == 0 );
end 


function datacells = removeElementsWithNoVertices( varargin )





datacells = varargin;
if nargin > 1
noVertices = cellfun( @( data )isempty( data.NumVertices ), datacells );
if all( noVertices )
datacells = datacells( 1 );
elseif any( noVertices )
datacells( noVertices ) = [  ];
end 
end 
end 


function S = encodeInStructure( data )
for prop = string( transpose( properties( data ) ) )
S.( prop ) = data.( prop );
end 
end 


function data = restoreFromStructure( data, S )
for prop = string( transpose( properties( data ) ) )
data.( prop ) = S.( prop );
end 
end 
end 


methods ( Access = protected )
function [ nvertices, c1, c2 ] = parenReferenceVertices( data, subs )
nvertices = data.NumVertices( subs{ : } );
[ s, e ] = map.shape.internal.HomogeneousData.startAndEnd( data.NumVertices, subs );
sSub = 1;
c1 = zeros( 1, sum( nvertices, 'all' ) );
c2 = c1;
for k = 1:length( e )
c1k = data.VertexCoordinate1( s( k ):e( k ) );
c2k = data.VertexCoordinate2( s( k ):e( k ) );
eSub = sSub + length( c1k ) - 1;
c1( sSub:eSub ) = c1k;
c2( sSub:eSub ) = c2k;
sSub = eSub + 1;
end 
end 


function [ nvertices, c1, c2 ] = parenDeleteVertices( data, subs )
nvertices = data.NumVertices;
nvertices( subs{ : } ) = [  ];
remove = map.shape.internal.HomogeneousData.removalIndex( data.NumVertices, subs );
c1 = data.VertexCoordinate1;
c2 = data.VertexCoordinate2;
c1( remove ) = [  ];
c2( remove ) = [  ];
end 
end 


methods ( Static, Access = protected )
function [ s, e ] = startAndEnd( num, subs )



e = cumsum( num( : ) );
s = 1 + [ 0;e( 1:end  - 1 ) ];
sz = size( num );
s = reshape( s, sz );
e = reshape( e, sz );
s = s( subs{ : } );
e = e( subs{ : } );
s = s( : );
e = e( : );









end 


function remove = removalIndex( num, subs )



[ s, e ] = map.shape.internal.HomogeneousData.startAndEnd( num, subs );
remove = false( 1, sum( num, "all" ) );
for k = 1:length( e )
remove( s( k ):e( k ) ) = true;
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpAJKkv0.p.
% Please follow local copyright laws when handling this file.

