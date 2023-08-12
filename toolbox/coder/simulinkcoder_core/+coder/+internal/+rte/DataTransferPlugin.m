function DataTransferPlugin( codeDescriptor, impFolder, buildInfo )





R36
codeDescriptor( 1, 1 )coder.codedescriptor.CodeDescriptor
impFolder( 1, : )char
buildInfo( 1, 1 )RTW.BuildInfo
end 

assert( isfolder( impFolder ) );


filename = coder.internal.rte.util.DataTransferFilename;
tObj = coder.internal.rte.DataTransferServiceGenerator( filename, impFolder );
tObj.generateRTEImplementation( codeDescriptor );


buildInfo.addSourceFiles( fullfile( impFolder, filename ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpDPIsqH.p.
% Please follow local copyright laws when handling this file.

