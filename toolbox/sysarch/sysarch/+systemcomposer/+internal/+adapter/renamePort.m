function renamePort( blkHdl, oldPortName, newPortName )

arguments
blkHdl( 1, 1 ){ mustBeNumeric };
oldPortName( 1, : )char;
newPortName( 1, : )char;
end 
ports = find_system( blkHdl, 'PortName', oldPortName );
set_param( ports( 1 ), 'PortName', newPortName );
end 
