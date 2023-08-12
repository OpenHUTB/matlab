classdef ( Sealed )OperationSpecification




















properties 

Height
Width
Channel
BatchSize
NumFilters
FilterSize
Stride
Dilation
PaddingSize
end 

properties ( Constant )
Datatype( 1, 1 )string = 'single'
ProcessingUnit( 1, 1 )string = 'CPU'
end 

methods 
function obj = OperationSpecification( nvps )

R36
nvps.Height( 1, 1 ){ mustBeInteger, mustBePositive }
nvps.Width( 1, 1 ){ mustBeInteger, mustBePositive }
nvps.Channel( 1, 1 ){ mustBeInteger, mustBePositive }
nvps.BatchSize( 1, 1 ){ mustBeInteger, mustBePositive }
nvps.NumFilters( 1, 1 ){ mustBeInteger, mustBePositive }
nvps.FilterSize( 1, 2 ){ mustBeInteger, mustBePositive }
nvps.Stride( 1, 2 ){ mustBeInteger, mustBePositive }
nvps.Dilation( 1, 2 ){ mustBeInteger, mustBePositive }
nvps.PaddingSize( 1, 4 ){ mustBeInteger, mustBeNonnegative }
end 

obj = dltargets.internal.assignNVPsToClassObject( obj, nvps );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpJSd7zk.p.
% Please follow local copyright laws when handling this file.

