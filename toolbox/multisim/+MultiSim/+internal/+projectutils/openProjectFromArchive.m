function project = openProjectFromArchive( archiveFile, destinationFolder )

arguments
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

