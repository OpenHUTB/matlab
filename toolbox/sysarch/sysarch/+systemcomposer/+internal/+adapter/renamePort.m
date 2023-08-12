function renamePort( blkHdl, oldPortName, newPortName )



R36
blkHdl( 1, 1 ){ mustBeNumeric };
oldPortName( 1, : )char;
newPortName( 1, : )char;
end 
ports = find_system( blkHdl, 'PortName', oldPortName );
set_param( ports( 1 ), 'PortName', newPortName );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpAlHxLI.p.
% Please follow local copyright laws when handling this file.

