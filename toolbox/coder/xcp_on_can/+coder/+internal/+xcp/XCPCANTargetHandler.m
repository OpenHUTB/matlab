




classdef XCPCANTargetHandler < coder.internal.xcp.XCPTargetHandler
properties ( SetAccess = private, GetAccess = private )
VendorName = '';
DeviceName = '';
ChannelNumber = 0;
Baudrate = 0;
CommandCANIDEBit = 0;
CommandCANID = 0;
ResponseCANIDEBit = 0;
ResponseCANID = 0;

CANChannel = [  ];
end 

methods ( Access = public )

function this = XCPCANTargetHandler( BuildDir, VendorName, DeviceName, ChannelNumber,  ...
Baudrate, CommandCANIDEBit, CommandCANID,  ...
ResponseCANIDEBit, ResponseCANID, SymbolsFileName )
this@coder.internal.xcp.XCPTargetHandler( BuildDir, SymbolsFileName );

this.VendorName = VendorName;
this.DeviceName = DeviceName;
this.ChannelNumber = ChannelNumber;
this.Baudrate = Baudrate;
this.CommandCANIDEBit = CommandCANIDEBit;
this.CommandCANID = CommandCANID;
this.ResponseCANIDEBit = ResponseCANIDEBit;
this.ResponseCANID = ResponseCANID;
end 
end 

methods ( Access = protected )

function connection = startTargetConnection( src, timeouts )


isVNTLicensed = license( 'checkout', 'vehicle_network_toolbox' );
if ~isVNTLicensed
DAStudio.error( 'coder_xcp:host:XcpOnCanRequiresVNT' );
end 


coder.internal.xcp.xcp_on_can.registerCANSupport
canSupport = onCleanup( @(  )coder.internal.xcp.xcp_on_can.unregisterCANSupport );

connection = coder.internal.connectivity.XcpTargetConnection( 'XcpOnCAN' );


connection.setSlaveInfo( 'timeoutValues', timeouts );


src.CANChannel = canChannel( src.VendorName, src.DeviceName, src.ChannelNumber );
configBusSpeed( src.CANChannel, src.Baudrate );


arch = computer( 'arch' );
converterPath = fullfile( toolboxdir( 'vnt' ), 'vnt', 'private', arch, 'canslconverter' );
devicePath = src.CANChannel.DevicePath;
connection.connect( devicePath, converterPath, src.CANChannel.AsyncioChannelOptions,  ...
src.CommandCANIDEBit, src.CommandCANID, src.ResponseCANIDEBit, src.ResponseCANID );
end 


function stopTargetConnection( src, connection )
connection.disconnect(  );


delete( src.CANChannel );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmphC_Bgm.p.
% Please follow local copyright laws when handling this file.

