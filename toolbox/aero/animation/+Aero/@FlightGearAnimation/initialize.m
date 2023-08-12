function initialize( h )





R36
h Aero.FlightGearAnimation
end 

arrayfun( @setUDPSocket, h )

end 

function setUDPSocket( h )
address = string( h.DestinationIpAddress );
port = string( h.DestinationPort );

if isempty( h.FGSocket )
h.FGSocket = matlabshared.network.internal.UDP( EnablePortSharing = true );
end 


goodHost = ( string( h.FGSocket.RemoteHost ) == address ) && ( string( h.FGSocket.RemotePort ) == port );


if goodHost && h.FGSocket.Connected
return 
elseif goodHost && ~h.FGSocket.Connected

try 
h.FGSocket.connect(  );
catch 
warning( message( "aero:FlightGearAnimation:ConnectionError", address, port ) )
end 
elseif ~goodHost && h.FGSocket.Connected

try 
h.FGSocket.setRemoteEndpoint( address.char(  ), port.double(  ) );
catch 
warning( message( "aero:FlightGearAnimation:ConnectionError", address, port ) )
end 
else 

try 
h.FGSocket.RemoteHost = address.char(  );
h.FGSocket.RemotePort = port.double(  );
h.FGSocket.connect(  );
catch 
warning( message( "aero:FlightGearAnimation:ConnectionError", address, port ) )
end 
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpZuDiaS.p.
% Please follow local copyright laws when handling this file.

