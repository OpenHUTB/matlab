function project = openProjectFromArchive( archiveFile, destinationFolder )


R36
archiveFile( 1, 1 )string
destinationFolder( 1, 1 )string
end 

simulink.multisim.internal.debuglog( "Extracting project archive " + string( archiveFile ) + " to " + string( destinationFolder ) );
unzip( archiveFile, destinationFolder );

mainProjectFolder = destinationFolder;
projectFiles = dir( fullfile( destinationFolder, "*.prj" ) );

if isempty( projectFiles )
mainProjectFolder = fullfile( destinationFolder, "main" );
end 
simulink.multisim.internal.debuglog( "Loading project" );
project = simulinkproject( mainProjectFolder );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp09WZz_.p.
% Please follow local copyright laws when handling this file.

