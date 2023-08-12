classdef PolygonData < map.shape.internal.LineStringData





methods ( Access = protected )
function data = defaultObject( ~ )

data = map.shape.internal.PolygonData;
end 
end 


methods 
function geometry = geometry( ~ )
geometry = "polygon";
end 


function type = geometryType( ~ )
type = uint8( 3 );
end 


function data = PolygonData( sz )









R36
sz = [ 1, 1 ];
end 
data.NumVertices = zeros( sz, "uint32" );
data.NumVertexSequences = zeros( sz, "uint32" );
end 


function num = numRingType( data, ringType )
q = ( data.RingType == ringType );
nvs = data.NumVertexSequences;
num = zeros( size( nvs ) );
e = 0;
for k = 1:numel( nvs )
s = e + 1;
e = s + nvs( k ) - 1;
num( k ) = sum( q( s:e ) );
end 
end 


function data = fromNumericVectors( data, v1, v2, handedness )
data = fromNumericVectors@map.shape.internal.LineStringData( data, v1, v2 );
data.RingType = polygonRingType( v1, v2, handedness );
end 


function data = fromCellArrays( data, c1, c2, handedness )
data = fromCellArrays@map.shape.internal.LineStringData( data, c1, c2 );
ringType = cell( 1, numel( c1 ) );
for k = 1:numel( c1 )
ringType{ k } = polygonRingType( c1{ k }, c2{ k }, handedness );
end 
data.RingType = [ ringType{ : } ];
end 


function [ vertexData, vertexIndices, shapeIndices ] = triangleStripData( data, method )










R36
data( 1, 1 )map.shape.internal.PolygonData
method( 1, 1 )string = "polyshape"
end 
if isscalar( data.NumVertexSequences )
[ vertexData, connectivityList ] = singlePolygonTriangleStripData(  ...
data.VertexCoordinate1, data.VertexCoordinate2,  ...
data.IndexOfLastVertex, method );
shapeIndices = ones( 1, height( connectivityList ), "uint32" );
else 














n = sum( data.NumVertices( : ) );
connectivityList = zeros( n, 3, "uint32" );
shapeIndices = zeros( 1, n, "uint32" );
vertexData = zeros( n, 2 );
ei = 0;
ev = 0;
if numel( data.NumVertexSequences ) > 1



es = cumsum( data.NumVertexSequences( : )' );
ss = 1 + [ 0, es( 1:end  - 1 ) ];
ec = cumsum( data.NumVertices( : )' );
sc = 1 + [ 0, ec( 1:end  - 1 ) ];

for k = 1:numel( data.NumVertexSequences )
n = data.NumVertexSequences( k );
if n > 0

indexOfLastVertex = data.IndexOfLastVertex( ss( k ):es( k ) );
x = data.VertexCoordinate1( sc( k ):ec( k ) );
y = data.VertexCoordinate2( sc( k ):ec( k ) );
[ vdata, connectivity ] = singlePolygonTriangleStripData(  ...
x, y, indexOfLastVertex, method );



si = ei + 1;
ei = ei + height( connectivity );
connectivityList( si:ei, : ) = ev + connectivity;
shapeIndices( 1, si:ei ) = k;


sv = ev + 1;
ev = ev + height( vdata );
vertexData( sv:ev, : ) = vdata;
end 
end 
end 

connectivityList( ( ei + 1 ):end , : ) = [  ];
shapeIndices( :, ( ei + 1 ):end  ) = [  ];
vertexData( ( ev + 1 ):end , : ) = [  ];




end 





vertexIndices = reshape( connectivityList', [ 1, numel( connectivityList ) ] );
end 
end 
end 


function ringType = polygonRingType( x, y, handedness )
if isempty( x )
ringType = uint8.empty( 1, 0 );
else 
if handedness == "right"
ringType = uint8( 2 - ispolycw( x( : )', y( : )' ) );
else 
ringType = uint8( 2 - ispolycw( y( : )', x( : )' ) );
end 
end 
end 


function [ vertexData, connectivityList ] ...
 = singlePolygonTriangleStripData( xin, yin, indexOfLastVertex, method )






[ x, y, indexOfLastVertex ] = filterIncompleteRings( xin, yin, indexOfLastVertex );
if isempty( indexOfLastVertex )
vertexData = double.empty( 0, 2 );
connectivityList = uint32.empty( 0, 3 );
else 
if method == "delaunaytri"
[ vertexData, connectivityList ] = triangulateWithConstrainedDelaunay( x, y, indexOfLastVertex );
else 
[ vertexData, connectivityList ] = triangulateWithPolygonShape( x, y, indexOfLastVertex );
end 
connectivityList = uint32( connectivityList );
if isempty( connectivityList )

vertexData = double.empty( 0, 2 );
end 
end 
end 


function [ x, y, indexOfLastVertex ] = filterIncompleteRings( x, y, indexOfLastVertex )

if ~isempty( indexOfLastVertex )
e = indexOfLastVertex;
s = 1 + [ 0, e( 1:end  - 1 ) ];
removeVertex = false( size( x ) );
for k = length( e ): - 1:1
sk = s( k );
ek = e( k );
incompleteRing = ek - sk < 3 || x( ek ) ~= x( sk ) || y( ek ) ~= y( sk );
if incompleteRing
removeVertex( sk:ek ) = true;
indexOfLastVertex( k ) = [  ];
indexOfLastVertex( k:end  ) = indexOfLastVertex( k:end  ) - ( ek - sk + 1 );
end 
end 
x( removeVertex ) = [  ];
y( removeVertex ) = [  ];
end 
end 


function [ vertexData, connectivityList ] ...
 = triangulateWithPolygonShape( x, y, indexOfLastVertex )




















[ xn, yn ] = map.shape.internal.LineStringData.insertNanDelimiters( x, y, indexOfLastVertex );
underlying = matlab.internal.polygon.builtin.cpolygon( xn, yn, "ccw", uint32( 0 ) );
[ connectivityList, vertexData ] = tristrip( underlying );
end 


function [ vertexData, connectivityList ] ...
 = triangulateWithConstrainedDelaunay( x, y, indexOfLastVertex )










x( indexOfLastVertex ) = [  ];
y( indexOfLastVertex ) = [  ];


constraints = constraintsMatrix( indexOfLastVertex );




w( 4 ) = warning( 'off', 'MATLAB:delaunayTriangulation:DupPtsWarnId' );
w( 3 ) = warning( 'off', 'MATLAB:delaunayTriangulation:ConsSplitPtWarnId' );
w( 2 ) = warning( 'off', 'MATLAB:delaunayTriangulation:DupPtsConsUpdatedWarnId' );
w( 1 ) = warning( 'off', 'MATLAB:delaunayTriangulation:ConsConsSplitWarnId' );
c = onCleanup( @(  )warning( w ) );
tri = delaunayTriangulation( x', y', constraints );


vertexData = tri.Points;
connectivityList = tri.ConnectivityList( isInterior( tri ), : );
end 


function constraints = constraintsMatrix( indexOfLastVertex )










m = indexOfLastVertex( end  );



i1 = ( 1:( m - 1 ) )';



i2 = ( 2:m )';





indexOfFirstVertex = 1 + [ 0, indexOfLastVertex( 1:end  - 1 ) ];
last = zeros( m, 1, 'uint32' );
for k = 1:length( indexOfLastVertex )
i2( i2 == indexOfLastVertex( k ) ) = indexOfFirstVertex( k );
last( indexOfLastVertex( k ) ) = 1;
end 
last( end  ) = [  ];


adjustment = cumsum( last );
i1 = i1 - adjustment;
i2 = i2 - adjustment;



remove = indexOfLastVertex( 1:end  - 1 );
i1( remove ) = [  ];
i2( remove ) = [  ];


constraints = double( [ i1, i2 ] );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpyUFzMr.p.
% Please follow local copyright laws when handling this file.

