function createUDPPacketBusObj( dataLength )




















R36
dataLength( 1, 1 ){ mustBeInteger, mustBeGreaterThan( dataLength, 0 ), mustBeLessThan( dataLength, 65508 ) }
end 



busObjExists = false;

if isempty( bdroot )

if evalin( 'base', "exist('UDP_Packet', 'var')" )
UDPPacketBusObj = evalin( 'base', "UDP_Packet" );
busObjExists = true;
end 
else 
if Simulink.data.existsInGlobal( bdroot, "UDP_Packet" )
UDPPacketBusObj = Simulink.data.evalinGlobal( bdroot, "UDP_Packet" );
busObjExists = true;
end 
end 

if busObjExists

assert( isa( UDPPacketBusObj, 'Simulink.Bus' ), getString( message( 'slrealtime:UDP:NotBusObj' ) ) );
assert( numel( UDPPacketBusObj.Elements ) == 4, getString( message( 'slrealtime:UDP:InvalidBusObj' ) ) );
assert( UDPPacketBusObj.Elements( 1 ).Name == "IP_Address" &&  ...
UDPPacketBusObj.Elements( 2 ).Name == "IP_Port" &&  ...
UDPPacketBusObj.Elements( 3 ).Name == "Length" &&  ...
UDPPacketBusObj.Elements( 4 ).Name == "Data",  ...
getString( message( 'slrealtime:UDP:InvalidBusObj' ) ) );
assert( UDPPacketBusObj.Elements( 1 ).DataType == "uint8" &&  ...
UDPPacketBusObj.Elements( 2 ).DataType == "uint16" &&  ...
UDPPacketBusObj.Elements( 3 ).DataType == "uint16" &&  ...
UDPPacketBusObj.Elements( 4 ).DataType == "uint8",  ...
getString( message( 'slrealtime:UDP:InvalidBusObj' ) ) );
assert( isequal( UDPPacketBusObj.Elements( 1 ).Dimensions, [ 4, 1 ] ) &&  ...
UDPPacketBusObj.Elements( 2 ).Dimensions == 1 &&  ...
UDPPacketBusObj.Elements( 3 ).Dimensions == 1 &&  ...
UDPPacketBusObj.Elements( 1 ).Dimensions( 2 ) == 1,  ...
getString( message( 'slrealtime:UDP:InvalidBusObj' ) ) );


currDataLength = UDPPacketBusObj.Elements( 4 ).Dimensions( 1 );
if currDataLength < dataLength

s = sprintf( "UDP_Packet.Elements(4).Dimensions(1) = %i;", dataLength );

if isempty( bdroot )
evalin( 'base', s );
else 
Simulink.data.evalinGlobal( bdroot, s );
end 
end 

else 

clear elems;
elems( 1 ) = Simulink.BusElement;
elems( 1 ).Name = 'IP_Address';
elems( 1 ).Dimensions = [ 4, 1 ];
elems( 1 ).DimensionsMode = 'Fixed';
elems( 1 ).DataType = 'uint8';
elems( 1 ).SampleTime =  - 1;
elems( 1 ).Complexity = 'real';
elems( 1 ).Min = [  ];
elems( 1 ).Max = [  ];
elems( 1 ).DocUnits = '';
elems( 1 ).Description = '';

elems( 2 ) = Simulink.BusElement;
elems( 2 ).Name = 'IP_Port';
elems( 2 ).Dimensions = 1;
elems( 2 ).DimensionsMode = 'Fixed';
elems( 2 ).DataType = 'uint16';
elems( 2 ).SampleTime =  - 1;
elems( 2 ).Complexity = 'real';
elems( 2 ).Min = [  ];
elems( 2 ).Max = [  ];
elems( 2 ).DocUnits = '';
elems( 2 ).Description = '';

elems( 3 ) = Simulink.BusElement;
elems( 3 ).Name = 'Length';
elems( 3 ).Dimensions = 1;
elems( 3 ).DimensionsMode = 'Fixed';
elems( 3 ).DataType = 'uint16';
elems( 3 ).SampleTime =  - 1;
elems( 3 ).Complexity = 'real';
elems( 3 ).Min = [  ];
elems( 3 ).Max = [  ];
elems( 3 ).DocUnits = '';
elems( 3 ).Description = '';

elems( 4 ) = Simulink.BusElement;
elems( 4 ).Name = 'Data';
elems( 4 ).Dimensions = [ dataLength, 1 ];
elems( 4 ).DimensionsMode = 'Fixed';
elems( 4 ).DataType = 'uint8';
elems( 4 ).SampleTime =  - 1;
elems( 4 ).Complexity = 'real';
elems( 4 ).Min = [  ];
elems( 4 ).Max = [  ];
elems( 4 ).DocUnits = '';
elems( 4 ).Description = '';

UDP_Packet = Simulink.Bus;
UDP_Packet.HeaderFile = '';
UDP_Packet.Description = '';
UDP_Packet.DataScope = 'Auto';
UDP_Packet.Alignment =  - 1;
UDP_Packet.Elements = elems;
clear elems;

if isempty( bdroot )
assignin( 'base', 'UDP_Packet', UDP_Packet );
else 
Simulink.data.assigninGlobal( bdroot, 'UDP_Packet', UDP_Packet );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmplx4b_e.p.
% Please follow local copyright laws when handling this file.

