classdef BasicType < handle





properties ( SetAccess = private )



Name




EmitName



PrimitiveType


NumBits


ContainerNumBits


IsSigned
end 

methods 
function this = BasicType( name, emitName, primitiveType,  ...
numBits, containerNumBits, isSigned )
R36
name
emitName
primitiveType
numBits( 1, 1 )double = 0
containerNumBits( 1, 1 )double = 0
isSigned = [  ]
end 
if numBits ~= 0
assert( ~isempty( isSigned ), 'IsSigned must be set' )
end 
this.Name = name;
this.EmitName = emitName;
this.PrimitiveType = primitiveType;
this.NumBits = numBits;
this.ContainerNumBits = containerNumBits;
this.IsSigned = isSigned;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpH17GAV.p.
% Please follow local copyright laws when handling this file.

