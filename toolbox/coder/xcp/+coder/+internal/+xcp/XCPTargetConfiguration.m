classdef XCPTargetConfiguration < handle









properties ( SetAccess = private, GetAccess = public )
Transport
AddressGranularity
end 

properties 
MaxDAQ = double( 0xFFFF )
MinDAQ = 0
MaxEventChannel = 128
MaxCTOSize
MaxDTOSize
IdentificationFieldSizeInBytes = 1
TimestampSizeInBytes = 4
MaxODTEntrySize
end 

methods ( Access = public )
function obj = XCPTargetConfiguration( transport, addressGranularity )
R36
transport( 1, : )char
addressGranularity( 1, 1 )double{ mustBeMember( addressGranularity, [ 1, 2, 4 ] ) } = 1
end 
obj.Transport = transport;
obj.AddressGranularity = addressGranularity;


switch obj.Transport
case Simulink.ExtMode.Transports.XCPSerial.Transport
obj.MaxCTOSize = double( 0xFF );
obj.MaxDTOSize = double( 0xFFFC );
obj.MaxODTEntrySize = double( 0xFF );
case Simulink.ExtMode.Transports.XCPTCP.Transport
obj.MaxCTOSize = double( 0xFF );
obj.MaxDTOSize = double( 0xFFFC );
obj.MaxODTEntrySize = double( 0xFF );
case Simulink.ExtMode.Transports.XCPCAN.Transport
obj.MaxCTOSize = double( 0x08 );
obj.MaxDTOSize = double( 0x0008 );


obj.MaxODTEntrySize = floor( double( 0x07 ) / addressGranularity );
otherwise 
DAStudio.error( 'coder_xcp:host:InvalidXcpTransport', obj.Transport );
end 
end 
end 

methods 
function set.MaxDAQ( obj, val )

if ( val < 0 ) || ( val > 0xFFFF )
DAStudio.error( 'coder_xcp:host:InvalidMaxDAQ' );
end 
obj.MaxDAQ = double( val );
end 

function set.MinDAQ( obj, val )

if ( val < 0 ) || ( val > 0xFF )
DAStudio.error( 'coder_xcp:host:InvalidMinDAQ' );
end 
obj.MinDAQ = double( val );
end 

function set.MaxEventChannel( obj, val )

if ( val < 0 ) || ( val > 0xFFFF )
DAStudio.error( 'coder_xcp:host:InvalidMaxEventChannel' );
end 
obj.MaxEventChannel = double( val );
end 

function set.MaxCTOSize( obj, val )

if ( val < 8 ) || ( val > 0xFF )
DAStudio.error( 'coder_xcp:host:InvalidMaxCTOSize' );
end 
obj.MaxCTOSize = double( val );
end 

function set.MaxDTOSize( obj, val )

if ( val < 8 ) || ( val > 0xFFFF )
DAStudio.error( 'coder_xcp:host:InvalidMaxDTOSize' );
end 
obj.MaxDTOSize = double( val );
end 

function set.MaxODTEntrySize( obj, val )

if ( val < 0 ) || ( val > 0xFF )
DAStudio.error( 'coder_xcp:host:InvalidMaxODTEntrySize' );
end 
obj.MaxODTEntrySize = double( val );
end 

function set.IdentificationFieldSizeInBytes( obj, val )

if ( val < 1 ) || ( val > 4 )
DAStudio.error( 'coder_xcp:host:InvalidIdentificationFieldSize' );
end 
obj.IdentificationFieldSizeInBytes = double( val );
end 

function set.TimestampSizeInBytes( obj, val )

if ( val ~= 1 ) && ( val ~= 2 ) && ( val ~= 4 )
DAStudio.error( 'coder_xcp:host:InvalidTimestampSize' );
end 
obj.TimestampSizeInBytes = double( val );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpC9ykHd.p.
% Please follow local copyright laws when handling this file.

