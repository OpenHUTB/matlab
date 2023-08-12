function openVitisHLSPrj( dirName )




curDir = pwd;
cd( dirName );

system( sprintf( "vitis_hls -p vitis_prj &" ) );
cd( curDir );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpXC4Z77.p.
% Please follow local copyright laws when handling this file.

