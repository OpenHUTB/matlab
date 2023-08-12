classdef HeterogeneousData < map.shape.internal.Data





properties 
GeometryType uint8 = 0
PointData( 1, 1 )map.shape.internal.PointData = map.shape.internal.PointData( [ 1, 0 ] )
LineStringData( 1, 1 )map.shape.internal.LineStringData = map.shape.internal.LineStringData( [ 1, 0 ] )
PolygonData( 1, 1 )map.shape.internal.PolygonData = map.shape.internal.PolygonData( [ 1, 0 ] )
end 


methods 
function geometry = geometry( ~ )
geometry = "heterogeneous";
end 


function data = HeterogeneousData( dataIn )
if nargin > 0

validateattributes( dataIn, "map.shape.internal.Data", {  } )
sz = arraySize( dataIn, {  } );
switch ( class( dataIn ) )
case "map.shape.internal.PointData"
data.PointData = dataIn;
data.PointData.NumVertices = data.PointData.NumVertices( : )';
data.GeometryType = 1 + zeros( sz );
case "map.shape.internal.LineStringData"
data.LineStringData = dataIn;
data.LineStringData.NumVertexSequences = data.LineStringData.NumVertexSequences( : )';
data.LineStringData.NumVertices = data.LineStringData.NumVertices( : )';
data.GeometryType = 2 + zeros( sz );
case "map.shape.internal.PolygonData"
data.PolygonData = dataIn;
data.PolygonData.NumVertexSequences = data.PolygonData.NumVertexSequences( : )';
data.PolygonData.NumVertices = data.PolygonData.NumVertices( : )';
data.GeometryType = 3 + zeros( sz );
otherwise 
data = dataIn;
end 
end 
end 


function data = fromStructInput( data, S, vertexCoordinateField1, vertexCoordinateField2 )


data.GeometryType = S.GeometryType;






geometryType = S.GeometryType( : )';
S.NumVertices = reshape( S.NumVertices, size( geometryType ) );
S.NumVertexSequences = reshape( S.NumVertexSequences, size( geometryType ) );


isPoint = ( geometryType == 1 );
isLineString = ( geometryType == 2 );
isPolygon = ( geometryType == 3 );


I = [  ...
makeStruct( 1, S.NumVertices( isPoint ), S.NumVertices( isPoint ) ),  ...
makeStruct( 2, S.NumVertices( isLineString ), S.NumVertexSequences( isLineString ) ),  ...
makeStruct( 3, S.NumVertices( isPolygon ), S.NumVertexSequences( isPolygon ) ) ];






numElements = numel( S.GeometryType );
ed = zeros( size( I ) );
e = 0;
for k = 1:numElements
n = S.NumVertexSequences( k );
if n > 0
t = S.GeometryType( k );
s = e + 1;
e = e + n;
sd = ed( t ) + 1;
ed( t ) = ed( t ) + n;
I( t ).IndexOfLastVertex( sd:ed( t ) ) = S.IndexOfLastVertex( s:e );
I( t ).RingType( sd:ed( t ) ) = S.RingType( s:e );
end 
end 



ed = zeros( size( I ) );
e = 0;
for k = 1:numElements
n = S.NumVertices( k );
if n > 0
t = S.GeometryType( k );
s = e + 1;
e = e + n;
sd = ed( t ) + 1;
ed( t ) = ed( t ) + n;
I( t ).Coordinate1( sd:ed( t ) ) = S.Coordinate1( s:e );
I( t ).Coordinate2( sd:ed( t ) ) = S.Coordinate2( s:e );
end 
end 





data.PointData = fromStructInput( data.PointData,  ...
I( 1 ), vertexCoordinateField1, vertexCoordinateField2 );

data.LineStringData = fromStructInput( data.LineStringData,  ...
I( 2 ), vertexCoordinateField1, vertexCoordinateField2 );

data.PolygonData = fromStructInput( data.PolygonData,  ...
I( 3 ), vertexCoordinateField1, vertexCoordinateField2 );
end 


function S = toStructOutput( data, vertexCoordinateField1, vertexCoordinateField2 )




D = [  ...
toStructOutput( data.PointData, vertexCoordinateField1, vertexCoordinateField2 ),  ...
toStructOutput( data.LineStringData, vertexCoordinateField1, vertexCoordinateField2 ),  ...
toStructOutput( data.PolygonData, vertexCoordinateField1, vertexCoordinateField2 ) ];


S = struct(  ...
"NumVertexSequences", initfield( D, "NumVertexSequences" ),  ...
"NumVertices", initfield( D, "NumVertices" ),  ...
"IndexOfLastVertex", initfield( D, "IndexOfLastVertex" ),  ...
"RingType", initfield( D, "RingType" ),  ...
"Coordinate1", initfield( D, "Coordinate1" ),  ...
"Coordinate2", initfield( D, "Coordinate2" ),  ...
"GeometryType", initfield( D, "GeometryType" ) );

function value = initfield( D, fieldname )
len = numel( D( 1 ).( fieldname ) ) + numel( D( 2 ).( fieldname ) ) + numel( D( 3 ).( fieldname ) );
value = zeros( 1, len, "like", D( 1 ).( fieldname ) );
end 





numElements = numel( data.GeometryType );
ed = zeros( size( D ) );
e = 0;
for k = 1:numElements
t = data.GeometryType( k );
e = e + 1;
ed( t ) = ed( t ) + 1;
S.GeometryType( e ) = t;
S.NumVertexSequences( e ) = D( t ).NumVertexSequences( ed( t ) );
S.NumVertices( e ) = D( t ).NumVertices( ed( t ) );
end 





ed = zeros( size( D ) );
e = 0;
for k = 1:numElements
n = S.NumVertexSequences( k );
if n > 0
t = data.GeometryType( k );
s = e + 1;
e = e + n;
sd = ed( t ) + 1;
ed( t ) = ed( t ) + n;
S.IndexOfLastVertex( s:e ) = D( t ).IndexOfLastVertex( sd:ed( t ) );
S.RingType( s:e ) = D( t ).RingType( sd:ed( t ) );
end 
end 



ed = zeros( size( D ) );
e = 0;
for k = 1:numElements
n = S.NumVertices( k );
if n > 0
t = data.GeometryType( k );
s = e + 1;
e = e + n;
sd = ed( t ) + 1;
ed( t ) = ed( t ) + n;
S.Coordinate1( s:e ) = D( t ).Coordinate1( sd:ed( t ) );
S.Coordinate2( s:e ) = D( t ).Coordinate2( sd:ed( t ) );
end 
end 


sz = size( data.GeometryType );
S.NumVertexSequences = reshape( S.NumVertexSequences, sz );
S.NumVertices = reshape( S.NumVertices, sz );
S.GeometryType = reshape( S.GeometryType, sz );
end 


function tf = isHomogeneous( data )
geometryType = int8( data.GeometryType );
tf = ~isempty( geometryType ) && ( ( numel( geometryType ) < 2 ) || all( diff( geometryType( : ) ) == 0 ) );
end 


function tf = isSelfConsistent( data )

geometryType = data.GeometryType( : );
numPointData = sum( geometryType == 1 );
numLineStringData = sum( geometryType == 2 );
numPolygonData = sum( geometryType == 3 );
tf = isSelfConsistent( data.PointData ) ...
 && isSelfConsistent( data.LineStringData ) ...
 && isSelfConsistent( data.PolygonData ) ...
 && numel( data.PointData.NumVertices ) == numPointData ...
 && numel( data.LineStringData.NumVertices ) == numLineStringData ...
 && numel( data.PolygonData.NumVertices ) == numPolygonData;
end 


function tf = ismultipoint( data )

tf = false( size( data.GeometryType ) );
points = ( data.GeometryType( : ) == 1 );
tf( points ) = ismultipoint( data.PointData );
end 


function tf = isemptyArray( data )
R36
data( 1, 1 )map.shape.internal.HeterogeneousData
end 
tf = isempty( data.GeometryType );
end 


function len = arrayLength( data )
R36
data( 1, 1 )map.shape.internal.HeterogeneousData
end 
len = length( data.GeometryType );
end 


function sz = arraySize( data, args )
R36
data( 1, 1 )map.shape.internal.HeterogeneousData
args( 1, : )cell
end 
sz = size( data.GeometryType, args{ : } );
end 


function data = transposeArray( data )
R36
data( 1, 1 )map.shape.internal.HeterogeneousData
end 
if isvector( data.GeometryType )
data.GeometryType = transpose( data.GeometryType );
else 
data = transposeArray@map.shape.internal.Data( data );
end 
end 


function data = catArray( dim, dataIn )
R36
dim( 1, 1 )double{ mustBeInteger, mustBePositive }
end 
R36( Repeating )
dataIn( 1, 1 )map.shape.internal.HeterogeneousData
end 




geometryType = cellfun( @( obj )obj.GeometryType, dataIn, "UniformOutput", false );
geometryType = cat( dim, geometryType{ : } );
if dim > 1 || iscolumn( geometryType )

data = map.shape.internal.HeterogeneousData(  );
data.GeometryType = geometryType;
c1 = cellfun( @( obj )obj.PointData, dataIn, "UniformOutput", false );
c2 = cellfun( @( obj )obj.LineStringData, dataIn, "UniformOutput", false );
c3 = cellfun( @( obj )obj.PolygonData, dataIn, "UniformOutput", false );
c1 = removeElementsWithNoVertices( c1{ : } );
c2 = removeElementsWithNoVertices( c2{ : } );
c3 = removeElementsWithNoVertices( c3{ : } );



data.PointData = catArray( 2, c1{ : } );
data.LineStringData = catArray( 2, c2{ : } );
data.PolygonData = catArray( 2, c3{ : } );
else 








arrayIn = cellfun( @( obj )split( obj ), dataIn, "UniformOutput", false );
data = merge( cat( dim, arrayIn{ : } ) );
end 
end 


function data = reshapeArray( data, sz )
R36
data( 1, 1 )map.shape.internal.HeterogeneousData
sz( 1, : )cell
end 
data.GeometryType = reshape( data.GeometryType, sz{ : } );
end 


function data = parenReferenceArray( data, subs )
if ~isemptyArray( data.PointData )
data.PointData = parenReferenceArray( data.PointData, datasubs( data, subs, 1 ) );
end 
if ~isemptyArray( data.LineStringData )
data.LineStringData = parenReferenceArray( data.LineStringData, datasubs( data, subs, 2 ) );
end 
if ~isemptyArray( data.PolygonData )
data.PolygonData = parenReferenceArray( data.PolygonData, datasubs( data, subs, 3 ) );
end 
data.GeometryType = data.GeometryType( subs{ : } );
if isHomogeneous( data )
sz = size( data.GeometryType );
switch ( data.GeometryType( 1 ) )
case 1
data = data.PointData;
case 2
data = data.LineStringData;
case 3
data = data.PolygonData;
end 
data = reshapeArray( data, num2cell( sz ) );
end 
end 


function data = parenDeleteArray( data, subs )
if ~isemptyArray( data.PointData )
data.PointData = parenDeleteArray( data.PointData, datasubs( data, subs, 1 ) );
end 
if ~isemptyArray( data.LineStringData )
data.LineStringData = parenDeleteArray( data.LineStringData, datasubs( data, subs, 2 ) );
end 
if ~isemptyArray( data.PolygonData )
data.PolygonData = parenDeleteArray( data.PolygonData, datasubs( data, subs, 3 ) );
end 
data.GeometryType( subs{ : } ) = [  ];
if isHomogeneous( data )
sz = size( data.GeometryType );
switch ( data.GeometryType( 1 ) )
case 1
data = data.PointData;
case 2
data = data.LineStringData;
case 3
data = data.PolygonData;
end 
data = reshapeArray( data, num2cell( sz ) );
end 
end 


function tf = hasNoCoordinateData( data )
tf = true( size( data.GeometryType ) );
tf( data.GeometryType( : ) == 1 ) = hasNoCoordinateData( data.PointData )';
tf( data.GeometryType( : ) == 2 ) = hasNoCoordinateData( data.LineStringData )';
tf( data.GeometryType( : ) == 3 ) = hasNoCoordinateData( data.PolygonData )';
end 


function S = encodeInStructure( data )
S = struct(  ...
"GeometryType", data.GeometryType,  ...
"PointData", encodeInStructure( data.PointData ),  ...
"LineStringData", encodeInStructure( data.LineStringData ),  ...
"PolygonData", encodeInStructure( data.PolygonData ) );
end 


function data = restoreFromStructure( data, S )
data.GeometryType = S.GeometryType;
data.PointData = restoreFromStructure( data.PointData, S.PointData );
data.LineStringData = restoreFromStructure( data.LineStringData, S.LineStringData );
data.PolygonData = restoreFromStructure( data.PolygonData, S.PolygonData );
end 
end 


methods ( Access = protected )
function subs = datasubs( data, subs, geometry )
index = uint32( data.GeometryType == geometry );
index( index( : ) > 0 ) = ( 1:sum( index, 'all' ) )';
index = index( subs{ : } );
index( index == 0 ) = [  ];

index = reshape( index, [ 1, numel( index ) ] );
subs = { index };
end 


function array = split( data )
R36
data( 1, 1 )map.shape.internal.HeterogeneousData
end 

geometryType = data.GeometryType;
sz = num2cell( size( geometryType ) );
if isempty( geometryType )
array = data.empty( sz{ : } );
else 
array( sz{ : } ) = map.shape.internal.HeterogeneousData;
index = find( geometryType( : ) == 1 );
if ~isempty( index )
[ array( index ).GeometryType ] = deal( 1 );
pointData = split( data.PointData );
for k = 1:numel( index )
array( index( k ) ).PointData = pointData( k );
end 
end 

index = find( geometryType( : ) == 2 );
[ array( index ).GeometryType ] = deal( 2 );
lineStringData = split( data.LineStringData );
if ~isempty( index )
for k = 1:numel( index )
array( index( k ) ).LineStringData = lineStringData( k );
end 
end 

index = find( geometryType( : ) == 3 );
[ array( index ).GeometryType ] = deal( 3 );
polygonData = split( data.PolygonData );
if ~isempty( index )
for k = 1:numel( index )
array( index( k ) ).PolygonData = polygonData( k );
end 
end 
end 
end 


function data = merge( array )
if isempty( array )
data = map.shape.internal.HeterogeneousData(  );
data.GeometryType = uint8.empty( size( array ) );
elseif isscalar( array )
data = array;
else 
assert( all( arrayfun( @( obj )isscalar( obj.GeometryType ), array ), "all" ),  ...
"map:shape:InternalError", "Internal error in %s.",  ...
"map.shape.internal.HeterogeneousData" )

data = map.shape.internal.HeterogeneousData(  );
sz = num2cell( size( array ) );
geometryType( sz{ : } ) = uint8( 0 );
for k = 1:numel( geometryType )
geometryType( k ) = array( k ).GeometryType;
end 
data.GeometryType = geometryType;

index = ( geometryType( : ) == 1 );
if any( index )
data.PointData = merge( [ array( index ).PointData ] );
end 

index = ( geometryType( : ) == 2 );
if any( index )
data.LineStringData = merge( [ array( index ).LineStringData ] );
end 

index = ( geometryType( : ) == 3 );
if any( index )
data.PolygonData = merge( [ array( index ).PolygonData ] );
end 
end 
end 
end 
end 


function S = makeStruct( geometryType, numVertices, numVertexSequences )
P = sum( numVertices );
M = sum( numVertexSequences );
S = struct(  ...
"GeometryType", geometryType + zeros( size( numVertices ), "uint8" ),  ...
"NumVertices", uint32( numVertices ),  ...
"NumVertexSequences", uint32( numVertexSequences ),  ...
"IndexOfLastVertex", zeros( 1, M, "uint32" ),  ...
"RingType", zeros( 1, M, "uint8" ),  ...
"Coordinate1", zeros( 1, P ),  ...
"Coordinate2", zeros( 1, P ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp9D0kcZ.p.
% Please follow local copyright laws when handling this file.

