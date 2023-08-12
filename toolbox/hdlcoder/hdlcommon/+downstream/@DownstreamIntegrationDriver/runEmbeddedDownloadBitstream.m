function [ status, result, validateCell ] = runEmbeddedDownloadBitstream( obj )


if obj.isIPCoreGen
[ status, result, validateCell ] = obj.hIP.runEmbeddedDownloadBitstream;
else 
error( message( 'hdlcommon:workflow:IPWorkflowOnly', 'runEmbeddedDownloadBitstream' ) );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpWvqyet.p.
% Please follow local copyright laws when handling this file.

