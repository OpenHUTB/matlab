classdef ( Sealed, Hidden )GLBFileWriter < handle




properties 
FileName( 1, : )char
Model{ validateModel }
VertexColors( :, 3 ){ mustBeNumeric }
EnableLighting( 1, 1 )logical
YUpCoordinate( 1, 1 )logical
MetallicFactor( 1, 1 )double
RoughnessFactor( 1, 1 )double
Opacity( 1, 1 )double
end 

properties ( Access = private )
UseColor( 1, 1 )logical = false
end 

methods 
function writer = GLBFileWriter( fileName, model, NameValueArgs )
R36
fileName
model
NameValueArgs.VertexColors = [  - 1,  - 1,  - 1 ]
NameValueArgs.EnableLighting = true
NameValueArgs.YUpCoordinate = true
NameValueArgs.MetallicFactor = 0.1
NameValueArgs.RoughnessFactor = 0.5
NameValueArgs.Opacity = 1
end 

writer.FileName = fileName;
writer.Model = model;
writer.VertexColors = NameValueArgs.VertexColors;

if ( NameValueArgs.VertexColors == [  - 1,  - 1,  - 1 ] )
writer.UseColor = false;
else 
writer.UseColor = true;
end 
writer.EnableLighting = NameValueArgs.EnableLighting;
writer.YUpCoordinate = NameValueArgs.YUpCoordinate;
writer.MetallicFactor = NameValueArgs.MetallicFactor;
writer.RoughnessFactor = NameValueArgs.RoughnessFactor;
writer.Opacity = NameValueArgs.Opacity;
end 

function write( writer )
fc = writer.fileContent;
fid = fopen( writer.FileName, "w" );
fwrite( fid, fc );
fclose( fid );
end 

end 

methods ( Access = private )
function fc = fileContent( writer )



tri = writer.Model;
connList = tri.ConnectivityList;
vertices = tri.Points;
normals = tri.faceNormal;
numFaces = size( connList, 1 );
numVertices = 3 * numFaces;
vertexColors = writer.VertexColors;
opacity = writer.Opacity;
if ( opacity == 1 )
alphaMode = 'OPAQUE';
else 
alphaMode = 'BLEND';
end 


if ( writer.YUpCoordinate )
vertices = [ vertices( :, 2 ), vertices( :, 3 ), vertices( :, 1 ) ];
normals = [ normals( :, 2 ), normals( :, 3 ), normals( :, 1 ) ];
end 


[ minPosition, maxPosition ] = bounds( vertices );
vertices = vertices';


if size( normals, 1 ) == 1
minNormal = normals;
maxNormal = normals;
else 
[ minNormal, maxNormal ] = bounds( normals );
end 
normals = normals';

if ( writer.UseColor )
[ minColor, maxColor ] = bounds( vertexColors );
vertexColors = vertexColors';
end 


indices = connList';
indexList = reshape( indices, [ 1, numVertices ] );
vertexBuffer = reshape( vertices( :, indexList ), [ 1, 3 * numVertices ] );
vertexBuffer = typecast( single( vertexBuffer ), 'uint8' );
indexBuffer = 0:1:numVertices - 1;
indexBuffer = typecast( uint32( indexBuffer ), 'uint8' );
normalBuffer = reshape( [ normals;normals;normals ], [ 1, 3 * numVertices ] );
normalBuffer = typecast( single( normalBuffer ), 'uint8' );

if ( writer.UseColor )
colorBuffer = reshape( vertexColors( :, indexList ), [ 1, 3 * numVertices ] );
colorBuffer = typecast( single( colorBuffer ), 'uint8' );
end 


indexChunkSize = length( indexBuffer );
vertexChunkSize = length( vertexBuffer );
colorChunkSize = vertexChunkSize;
normalChunkSize = vertexChunkSize;



if ( ~writer.EnableLighting )

if ( writer.UseColor )
binaryChunkDataSize = vertexChunkSize + colorChunkSize + indexChunkSize;
colorAccessorByteOffset = vertexChunkSize;
verticesBufferViewSize = vertexChunkSize + colorChunkSize;
indicesBufferViewByteOffset = vertexChunkSize + colorChunkSize;
else 
binaryChunkDataSize = vertexChunkSize + indexChunkSize;
verticesBufferViewSize = vertexChunkSize;
indicesBufferViewByteOffset = vertexChunkSize;
end 
else 

if ( writer.UseColor )
binaryChunkDataSize = vertexChunkSize + normalChunkSize + colorChunkSize + indexChunkSize;
normalAccessorByteOffset = vertexChunkSize;
colorAccessorByteOffset = vertexChunkSize + normalChunkSize;
verticesBufferViewSize = vertexChunkSize + normalChunkSize + colorChunkSize;
indicesBufferViewByteOffset = vertexChunkSize + normalChunkSize + colorChunkSize;
else 
binaryChunkDataSize = vertexChunkSize + normalChunkSize + indexChunkSize;
normalAccessorByteOffset = vertexChunkSize;
verticesBufferViewSize = vertexChunkSize + normalChunkSize;
indicesBufferViewByteOffset = vertexChunkSize + normalChunkSize;
end 
end 



material = struct( 'baseColorFactor', [ 1, 1, 1, opacity ],  ...
'metallicFactor', writer.MetallicFactor,  ...
'roughnessFactor', writer.RoughnessFactor );
if ( ~writer.EnableLighting )
extensions = struct( 'KHR_materials_unlit', struct(  ) );
end 


verticesAccessor = struct(  ...
'componentType', 5126,  ...
'count', numVertices,  ...
'min', minPosition,  ...
'max', maxPosition,  ...
'type', 'VEC3',  ...
'bufferView', 0,  ...
'byteOffset', 0 );
if ( writer.EnableLighting )
normalsAccessor = struct(  ...
'componentType', 5126,  ...
'count', numVertices,  ...
'min', minNormal,  ...
'max', maxNormal,  ...
'type', 'VEC3',  ...
'bufferView', 0,  ...
'byteOffset', normalAccessorByteOffset );
end 
if ( writer.UseColor )
colorsAccessor = struct(  ...
'componentType', 5126,  ...
'count', numVertices,  ...
'min', minColor,  ...
'max', maxColor,  ...
'type', 'VEC3',  ...
'bufferView', 0,  ...
'byteOffset', colorAccessorByteOffset );
end 
indicesAccessor = struct(  ...
'componentType', 5125,  ...
'count', numVertices,  ...
'min', { { 0 } },  ...
'max', { { numVertices - 1 } },  ...
'type', 'SCALAR',  ...
'bufferView', 1,  ...
'byteOffset', 0 );


verticesBufferView = struct(  ...
'buffer', 0,  ...
'byteLength', verticesBufferViewSize,  ...
'byteOffset', 0,  ...
'byteStride', 12,  ...
'target', 34962 );
indicesBufferView = struct(  ...
'buffer', 0,  ...
'byteLength', indexChunkSize,  ...
'byteOffset', indicesBufferViewByteOffset,  ...
'target', 34963 );



if ( ~writer.EnableLighting )

glbMaterial = { struct( 'pbrMetallicRoughness', material, 'extensions', extensions, 'alphaMode', alphaMode, 'doubleSided', true ) };
if ( writer.UseColor )
glbAccessors = { verticesAccessor, colorsAccessor, indicesAccessor };
glbMeshes = { struct( 'primitives', { { struct( 'attributes', struct( 'POSITION', 0, 'COLOR_0', 1 ), 'indices', 2, 'material', 0, 'mode', 4 ) } } ) };
else 
glbAccessors = { verticesAccessor, indicesAccessor };
glbMeshes = { struct( 'primitives', { { struct( 'attributes', struct( 'POSITION', 0 ), 'indices', 1, 'material', 0, 'mode', 4 ) } } ) };
end 
else 

glbMaterial = { struct( 'pbrMetallicRoughness', material, 'alphaMode', alphaMode, 'doubleSided', true ) };
if ( writer.UseColor )
glbAccessors = { verticesAccessor, normalsAccessor, colorsAccessor, indicesAccessor };
glbMeshes = { struct( 'primitives', { { struct( 'attributes', struct( 'POSITION', 0, 'NORMAL', 1, 'COLOR_0', 2 ), 'indices', 3, 'material', 0, 'mode', 4 ) } } ) };
else 
glbAccessors = { verticesAccessor, normalsAccessor, indicesAccessor };
glbMeshes = { struct( 'primitives', { { struct( 'attributes', struct( 'POSITION', 0, 'NORMAL', 1 ), 'indices', 2, 'material', 0, 'mode', 4 ) } } ) };
end 
end 


jsonData = struct(  ...
'accessors', { glbAccessors },  ...
'asset', struct( 'generator', 'MathWorks', 'version', '2.0' ),  ...
'buffers', { { struct( 'byteLength', binaryChunkDataSize ) } },  ...
'bufferViews', { { verticesBufferView, indicesBufferView } },  ...
'extensionsUsed', { { 'KHR_materials_unlit' } },  ...
'extensionsRequired', { { 'KHR_materials_unlit' } },  ...
'materials', { glbMaterial },  ...
'meshes', { glbMeshes },  ...
'nodes', { { struct( 'mesh', 0 ) } },  ...
'scene', 0,  ...
'scenes', { { struct( 'nodes', { { 0 } } ) } } );
jsonChunk = jsonencode( jsonData );
jsonChunk = unicode2native( jsonChunk );
jsonChunkLength = length( jsonChunk );


binaryChunkOffset = 20 + jsonChunkLength;
padding = 3 - mod( binaryChunkOffset - 1, 4 );
totalSize = binaryChunkOffset + padding + binaryChunkDataSize + 8;
fc = zeros( 1, totalSize, 'uint8' );


fc( 1:4 ) = uint8( 'glTF' );
fc( 5:8 ) = typecast( uint32( 2 ), 'uint8' );
fc( 9:12 ) = typecast( uint32( totalSize ), 'uint8' );
fc( 13:16 ) = typecast( uint32( jsonChunkLength + padding ), 'uint8' );
fc( 17:20 ) = uint8( 'JSON' );
fc( 21:binaryChunkOffset ) = jsonChunk;
for i = 1:padding
fc( binaryChunkOffset + i ) = 32;
end 


binaryChunkOffset = binaryChunkOffset + padding;
fc( binaryChunkOffset + 1:binaryChunkOffset + 4 ) = typecast( uint32( binaryChunkDataSize ), 'uint8' );
fc( binaryChunkOffset + 5:binaryChunkOffset + 7 ) = uint8( 'BIN' );
fc( binaryChunkOffset + 9:binaryChunkOffset + 8 + vertexChunkSize ) = vertexBuffer;



if ( ~writer.EnableLighting )

if ( writer.UseColor )
fc( binaryChunkOffset + 9 + vertexChunkSize:binaryChunkOffset + 8 + 2 * vertexChunkSize ) = colorBuffer;
fc( binaryChunkOffset + 9 + vertexChunkSize + colorChunkSize:totalSize ) = indexBuffer;
else 
fc( binaryChunkOffset + 9 + vertexChunkSize:totalSize ) = indexBuffer;
end 
else 

if ( writer.UseColor )
fc( binaryChunkOffset + 9 + vertexChunkSize:binaryChunkOffset + 8 + vertexChunkSize + normalChunkSize ) = normalBuffer;
fc( binaryChunkOffset + 9 + vertexChunkSize + normalChunkSize: ...
binaryChunkOffset + 8 + vertexChunkSize + normalChunkSize + colorChunkSize ) = colorBuffer;
fc( binaryChunkOffset + 9 + vertexChunkSize + normalChunkSize + colorChunkSize:totalSize ) = indexBuffer;
else 
fc( binaryChunkOffset + 9 + vertexChunkSize:binaryChunkOffset + 8 + vertexChunkSize + normalChunkSize ) = normalBuffer;
fc( binaryChunkOffset + 9 + vertexChunkSize + normalChunkSize:totalSize ) = indexBuffer;
end 
end 
end 
end 
end 

function validateModel( model )
if ~isempty( model )
validateattributes( model.Points, { 'numeric' }, { 'ncols', 3 }, '', 'Model' );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpTum2tl.p.
% Please follow local copyright laws when handling this file.

