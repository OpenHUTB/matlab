classdef PointData < map.shape.internal.HomogeneousData


























methods 
function geometry = geometry( ~ )
geometry = "point";
end 


function type = geometryType( ~ )
type = uint8( 1 );
end 


function data = PointData( sz )







R36
sz = [ 1, 1 ];
end 
data.NumVertices = zeros( sz, "uint32" );
end 


function data = fromStructInput( data, S,  ...
vertexCoordinateField1, vertexCoordinateField2 )

data.NumVertices = S.NumVertices;
data.VertexCoordinate1 = S.( vertexCoordinateField1 );
data.VertexCoordinate2 = S.( vertexCoordinateField2 );
end 


function S = toStructOutput( data,  ...
vertexCoordinateField1, vertexCoordinateField2 )



S = struct(  ...
"NumVertexSequences", [  ],  ...
"NumVertices", [  ],  ...
"IndexOfLastVertex", [  ],  ...
"RingType", [  ],  ...
"Coordinate1", [  ],  ...
"Coordinate2", [  ],  ...
"GeometryType", [  ] );

sz = size( data.NumVertices );
S.GeometryType = geometryType( data ) + zeros( sz, "uint8" );
S.NumVertexSequences = ones( sz, "uint32" );
S.NumVertices = data.NumVertices;
n = prod( sz );
S.IndexOfLastVertex = transpose( data.NumVertices( : ) );
S.RingType = zeros( 1, n, "uint8" );
S.( vertexCoordinateField1 ) = data.VertexCoordinate1;
S.( vertexCoordinateField2 ) = data.VertexCoordinate2;
end 


function data = fromNumericInput( data, v1, v2 )



data.VertexCoordinate1 = v1( : )';
data.VertexCoordinate2 = v2( : )';
data.NumVertices = ones( size( v1 ), "uint32" );
if anynan( data.VertexCoordinate1 )
n = isnan( data.VertexCoordinate1 );
data.VertexCoordinate1( n ) = [  ];
data.VertexCoordinate2( n ) = [  ];
data.NumVertices( n ) = 0;
end 
end 


function data = fromCellInput( data, c1, c2 )







data.NumVertices = uint32( cellfun( @( x )numel( x ), c1 ) );
v = zeros( 1, sum( data.NumVertices, "all" ) );
data.VertexCoordinate1 = v;
data.VertexCoordinate2 = v;
ev = 0;
for k = 1:numel( c1 )
v1 = c1{ k };
v2 = c2{ k };
if anynan( v1 )
n = isnan( v1 );
v1( n ) = [  ];
v2( n ) = [  ];
data.NumVertices( k ) = data.NumVertices( k ) - sum( n );
end 
sv = ev + 1;
ev = ev + numel( v1 );
data.VertexCoordinate1( sv:ev ) = v1;
data.VertexCoordinate2( sv:ev ) = v2;
end 


sv = ev + 1;
data.VertexCoordinate1( sv:end  ) = [  ];
data.VertexCoordinate2( sv:end  ) = [  ];
end 


function [ c1, c2 ] = toCellArrays( data )








sz = size( data.NumVertices );
if allSinglePoints( data )
c1 = reshape( num2cell( data.VertexCoordinate1 ), sz );
c2 = reshape( num2cell( data.VertexCoordinate2 ), sz );
else 
c1 = cell( sz );
c2 = cell( sz );
nv = data.NumVertices;
sv = 1;
for k = 1:numel( c1 )
ev = sv + nv( k ) - 1;
c1{ k } = data.VertexCoordinate1( sv:ev );
c2{ k } = data.VertexCoordinate2( sv:ev );
sv = ev + 1;
end 
end 
end 


function tf = isSelfConsistent( data )

R36
data( 1, 1 )map.shape.internal.PointData
end 
tf = isequal(  ...
sum( data.NumVertices( : ) ),  ...
length( data.VertexCoordinate1 ),  ...
length( data.VertexCoordinate2 ) );
end 


function data = transposeArray( data )
R36
data( 1, 1 )map.shape.internal.PointData
end 
if isvector( data.NumVertices )
data.NumVertices = transpose( data.NumVertices );
else 
data = transposeArray@map.shape.internal.Data( data );
end 
end 


function data = flipArray( data, dim )
R36
data( 1, 1 )map.shape.internal.PointData
dim double{ mustBeScalarOrEmpty } = [  ]
end 
if allSinglePoints( data )

n = numel( data.NumVertices );
ind = reshape( uint32( 1:n ), size( data.NumVertices ) );
if isempty( dim )
nvertices = flip( data.NumVertices );
ind = flip( ind );
else 
nvertices = flip( data.NumVertices, dim );
ind = flip( ind, dim );
end 
data.NumVertices = nvertices;
data.VertexCoordinate1 = data.VertexCoordinate1( ind( : ) );
data.VertexCoordinate2 = data.VertexCoordinate2( ind( : ) );
else 
data = flipArray@map.shape.internal.Data( data, dim );
end 
end 


function data = catArray( dim, dataIn )
R36
dim( 1, 1 )double{ mustBeInteger, mustBePositive }
end 
R36( Repeating )
dataIn( 1, 1 )map.shape.internal.PointData
end 




numVertices = cellfun( @( obj )obj.NumVertices, dataIn, "UniformOutput", false );
numVertices = cat( dim, numVertices{ : } );
if dim > 1 || iscolumn( numVertices )

data = map.shape.internal.PointData;
data.NumVertices = numVertices;
c1 = cellfun( @( obj )obj.VertexCoordinate1, dataIn, "UniformOutput", false );
c2 = cellfun( @( obj )obj.VertexCoordinate2, dataIn, "UniformOutput", false );
data.VertexCoordinate1 = horzcat( c1{ : } );
data.VertexCoordinate2 = horzcat( c2{ : } );
elseif all( cellfun( @allSinglePoints, dataIn ), "all" )

data = map.shape.internal.PointData;
data.NumVertices = numVertices;
c1 = cellfun( @( obj )reshape( obj.VertexCoordinate1, size( obj.NumVertices ) ), dataIn, "UniformOutput", false );
c2 = cellfun( @( obj )reshape( obj.VertexCoordinate2, size( obj.NumVertices ) ), dataIn, "UniformOutput", false );
v1 = vertcat( c1{ : } );
v2 = vertcat( c2{ : } );
data.VertexCoordinate1 = v1( : )';
data.VertexCoordinate2 = v2( : )';
else 









arrayIn = cellfun( @( obj )split( obj ), dataIn, "UniformOutput", false );
data = merge( cat( dim, arrayIn{ : } ) );
end 
end 


function data = reshapeArray( data, sz )
R36
data( 1, 1 )map.shape.internal.PointData
sz( 1, : )cell
end 
data.NumVertices = reshape( data.NumVertices, sz{ : } );
end 


function data = parenReferenceArray( data, subs )
if ~isemptyArray( data )
if allSinglePoints( data )

nvertices = data.NumVertices( subs{ : } );
n = numel( data.NumVertices );
sz = size( data.NumVertices );
k = reshape( uint32( 1:n ), sz );
k = k( subs{ : } );
k = k( : );
c1 = data.VertexCoordinate1( k );
c2 = data.VertexCoordinate2( k );
else 
[ nvertices, c1, c2 ] = parenReferenceVertices( data, subs );
end 
data.NumVertices = nvertices;
data.VertexCoordinate1 = c1;
data.VertexCoordinate2 = c2;
end 
end 


function data = parenDeleteArray( data, subs )
if allSinglePoints( data )

nvertices = data.NumVertices;
nvertices( subs{ : } ) = [  ];
n = numel( data.NumVertices );
sz = size( data.NumVertices );
k = reshape( uint32( 1:n ), sz );
k( subs{ : } ) = [  ];
k = k( : );
c1 = data.VertexCoordinate1( k );
c2 = data.VertexCoordinate2( k );
else 
[ nvertices, c1, c2 ] = parenDeleteVertices( data, subs );
end 
data.NumVertices = nvertices;
data.VertexCoordinate1 = c1;
data.VertexCoordinate2 = c2;
end 


function data = parenAssignArray( data, subs, rhs )




if ~isempty( data.NumVertices ) && allSinglePoints( data ) && allSinglePoints( rhs )
nvertices = data.NumVertices;
nvertices( subs{ : } ) = rhs.NumVertices;
allSinglePointOutput = all( nvertices == uint32( 1 ), 'all' );
if allSinglePointOutput
sz = size( data.NumVertices );
c1 = reshape( data.VertexCoordinate1, sz );
c2 = reshape( data.VertexCoordinate2, sz );
sz = size( rhs.NumVertices );
c1( subs{ : } ) = reshape( rhs.VertexCoordinate1, sz );
c2( subs{ : } ) = reshape( rhs.VertexCoordinate2, sz );
c1 = c1( : )';
c2 = c2( : )';
data.NumVertices = nvertices;
data.VertexCoordinate1 = c1;
data.VertexCoordinate2 = c2;
else 
data = parenAssignArray@map.shape.internal.Data( data, subs, rhs );
end 
else 
data = parenAssignArray@map.shape.internal.Data( data, subs, rhs );
end 
end 


function tf = allSinglePoints( data )
tf = all( data.NumVertices == 1, "all" );
end 


function tf = ismultipoint( data )

tf = data.NumVertices > 1;
end 


function [ vertexData, shapeIndices ] = markerData( data )






vertexData = [ data.VertexCoordinate1( : ), data.VertexCoordinate2( : ) ];
n = height( vertexData );
if isempty( data.NumVertices )

shapeIndices = uint32.empty( 1, 0 );
elseif allSinglePoints( data )

shapeIndices = uint32( 1:n );
elseif isscalar( data.NumVertices )

shapeIndices = ones( 1, n, "uint32" );
else 

shapeIndices = zeros( 1, n, "uint32" );
ei = 0;
for k = 1:numel( data.NumVertices )
nv = data.NumVertices( k );
if nv > 0
si = ei + 1;
ei = ei + nv;
shapeIndices( si:ei ) = k;
end 
end 
end 
end 


function data = clip( data, limits1, limits2 )
outsideLimits = ~inBox2D(  ...
data.VertexCoordinate1, data.VertexCoordinate2, limits1, limits2 );
data.VertexCoordinate1( outsideLimits ) = [  ];
data.VertexCoordinate2( outsideLimits ) = [  ];
if allSinglePoints( data )
data.NumVertices( outsideLimits ) = 0;
else 
inLimits = ~outsideLimits;
e = 0;
for k = 1:numel( data.NumVertices )
s = e + 1;
e = e + data.NumVertices( k );
data.NumVertices( k ) = sum( inLimits( s:e ) );
end 
end 
end 


function [ inpoly, onboundary ] = isinterior( data, pshape )
sz = size( data.NumVertices );
if isempty( data.VertexCoordinate1 )
inpoly = false( sz );
onboundary = false( sz );
else 
[ in, on ] = isinterior( pshape,  ...
data.VertexCoordinate1, data.VertexCoordinate2 );
if allSinglePoints( data )
inpoly = reshape( in, sz );
onboundary = reshape( on, sz );
else 

inpoly = false( sz );
onboundary = false( sz );
e = 0;
for k = 1:numel( data.NumVertices )
n = data.NumVertices( k );
if n > 0

s = e + 1;
e = e + n;
inpoly( k ) = all( in( s:e ) );
onboundary( k ) = all( on( s:e ) );
end 
end 
end 
end 
end 
end 


methods ( Access = protected )
function array = split( data )



R36
data( 1, 1 )map.shape.internal.PointData
end 
sz = num2cell( size( data.NumVertices ) );
if isempty( data.NumVertices )
array = map.shape.internal.PointData.empty( sz{ : } );
else 
array( sz{ : } ) = map.shape.internal.PointData;
end 

ev = 0;
for k = 1:numel( array )
n = data.NumVertices( k );
sv = ev + 1;
ev = ev + n;
array( k ).NumVertices = n;
array( k ).VertexCoordinate1 = data.VertexCoordinate1( sv:ev );
array( k ).VertexCoordinate2 = data.VertexCoordinate2( sv:ev );
end 
end 


function data = merge( array )




assert( all( arrayfun( @( obj )isscalar( obj.NumVertices ), array ), "all" ) )

data = map.shape.internal.PointData;
data.NumVertices = zeros( size( array ), "uint32" );
for k = 1:numel( array )
data.NumVertices( k ) = array( k ).NumVertices;
end 

n = sum( data.NumVertices, "all" );
v = zeros( 1, n );
data.VertexCoordinate1 = v;
data.VertexCoordinate2 = v;
ev = 0;
for k = 1:numel( array )
sv = ev + 1;
ev = ev + data.NumVertices( k );
data.VertexCoordinate1( sv:ev ) = array( k ).VertexCoordinate1;
data.VertexCoordinate2( sv:ev ) = array( k ).VertexCoordinate2;
end 
end 
end 
end 


function tf = inBox2D( v1, v2, limits1, limits2 )
inXLimits1 = ( limits1( 1 ) <= v1 ) & ( v1 <= limits1( 2 ) );
inYLimits1 = ( limits2( 1 ) <= v2 ) & ( v2 <= limits2( 2 ) );
tf = inXLimits1 & inYLimits1;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp5uQxD2.p.
% Please follow local copyright laws when handling this file.

