function [ dimLen, hBT ] = getVectorTypeInfo( pirSignal, returnMatrixDim )


if nargin < 2
returnMatrixDim = false;
end 


if isa( pirSignal, 'hdlcoder.signal' )
hT = pirSignal.Type;
else 
hT = pirSignal;
end 

if ~hT.isArrayType

dimLen = 1;
elseif returnMatrixDim || numel( hT.Dimensions ) > 1
if hT.isRowVector

dimLen = [ 1, hT.Dimensions ];
elseif numel( hT.Dimensions ) == 1

dimLen = [ hT.Dimensions, 1 ];
else 

dimLen = hT.Dimensions;
end 
else 

dimLen = hT.Dimensions;
end 

dimLen = double( dimLen );

if hT.isArrayType
hBT = hT.BaseType;
else 
hBT = hT;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpUi0cEO.p.
% Please follow local copyright laws when handling this file.

