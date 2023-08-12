classdef Resize2DLayer < nnet.layer.Layer


properties 

IPSize( 1, 2 )uint16
OPSize( 1, 2 )uint16
Scale( 1, 2 )uint16




gtmode( 1, 1 )uint8




method( 1, 1 )uint8





nrmode( 1, 1 )uint8
end 

methods 
function obj = Resize2DLayer( ipSize, opSize, NV )



R36
ipSize( 1, 2 ){ mustBeNumeric }
opSize( 1, 2 ){ mustBeNumeric }
NV.Name( 1, 1 )string = 'resize'
NV.GeometricTransformMode{ mustBeMember( NV.GeometricTransformMode, { 'half-pixel', 'asymmetric' } ) } = 'half-pixel'
NV.Method{ mustBeMember( NV.Method, { 'nearest', 'bilinear' } ) } = 'nearest'
NV.NearestRoundingMode{ mustBeMember( NV.NearestRoundingMode, { 'round', 'floor', 'onnx-10' } ) } = 'round'
end 

obj.Name = NV.Name;
obj.IPSize = ipSize;
obj.OPSize = opSize;
obj.Scale = obj.OPSize( 1:2 ) ./ obj.IPSize( 1:2 );
assert( all( obj.Scale == floor( obj.Scale ) ) )

if strcmp( NV.GeometricTransformMode, 'half-pixel' )
obj.gtmode = 0;
elseif strcmp( NV.GeometricTransformMode, 'asymmetric' )
obj.gtmode = 1;
end 
if strcmp( NV.Method, 'nearest' )
obj.method = 0;
elseif strcmp( NV.Method, 'bilinear' )
obj.method = 1;
end 
if strcmp( NV.NearestRoundingMode, 'round' )
obj.nrmode = 0;
elseif strcmp( NV.NearestRoundingMode, 'floor' )
obj.nrmode = 1;
elseif strcmp( NV.NearestRoundingMode, 'onnx-10' )
obj.nrmode = 1;
end 
end 

function Z = predict( obj, X )


argin = {  };

if obj.gtmode == 0
argin = [ argin, { 'GeometricTransformMode', 'half-pixel' } ];
elseif obj.gtmode == 1
argin = [ argin, { 'GeometricTransformMode', 'asymmetric' } ];
end 

if obj.nrmode == 0
argin = [ argin, { 'NearestRoundingMode', 'round' } ];
elseif obj.nrmode == 1
argin = [ argin, { 'NearestRoundingMode', 'floor' } ];
elseif obj.nrmode == 2
argin = [ argin, { 'NearestRoundingMode', 'onnx-10' } ];
end 

if obj.method == 0
argin = [ argin, { 'Method', 'nearest' } ];
elseif obj.method == 1
argin = [ argin, { 'Method', 'bilinear' } ];
end 

rsz = resize2dLayer( 'OutputSize', obj.OPSize( 1:2 ), argin{ : } );
Z = rsz.predict( X );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp1aCbWy.p.
% Please follow local copyright laws when handling this file.

