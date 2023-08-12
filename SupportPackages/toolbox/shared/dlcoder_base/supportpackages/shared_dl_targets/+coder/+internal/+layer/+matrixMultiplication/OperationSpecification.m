classdef ( Sealed )OperationSpecification














properties 

M
K
N
end 

properties ( Constant )
Datatype( 1, 1 )string = 'single'
ProcessingUnit( 1, 1 )string = 'CPU'
end 

methods 
function obj = OperationSpecification( nvps )

R36
nvps.M( 1, 1 ){ mustBeInteger, mustBePositive }
nvps.K( 1, 1 ){ mustBeInteger, mustBePositive }
nvps.N( 1, 1 ){ mustBeInteger, mustBePositive }
end 

obj = dltargets.internal.assignNVPsToClassObject( obj, nvps );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpchwDDk.p.
% Please follow local copyright laws when handling this file.

