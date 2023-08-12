classdef TargetTypeInfo < coder.internal.HardwareTypeInfo




properties ( SetAccess = immutable )
WordSize( 1, 1 )double
ShiftRightIntArith( 1, 1 )logical
HWDeviceType
Endianess
IntDivRoundTo
PreprocMaxBitsSint double{ mustBeScalarOrEmpty } = [  ]
PreprocMaxBitsUint double{ mustBeScalarOrEmpty } = [  ]
end 

methods 

function this = TargetTypeInfo( hardwareInfoStruct )
this = this@coder.internal.HardwareTypeInfo( hardwareInfoStruct );
this.WordSize = hardwareInfoStruct.WordSize;
this.ShiftRightIntArith = hardwareInfoStruct.ShiftRightIntArith;
this.HWDeviceType = hardwareInfoStruct.HWDeviceType;
this.Endianess = hardwareInfoStruct.Endianess;
this.IntDivRoundTo = hardwareInfoStruct.IntDivRoundTo;
if isfield( hardwareInfoStruct, 'PreprocMaxBitsSint' )
this.PreprocMaxBitsSint = hardwareInfoStruct.PreprocMaxBitsSint;
this.PreprocMaxBitsUint = hardwareInfoStruct.PreprocMaxBitsUint;
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmptn2Cc2.p.
% Please follow local copyright laws when handling this file.

