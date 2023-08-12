function [ status, result, validateCell ] = runSWInterfaceGen( obj )


if obj.isIPCoreGen
[ status, result, validateCell ] = obj.hIP.runSWInterfaceGen;
else 
error( message( 'hdlcommon:workflow:IPWorkflowOnly', 'runSWInterfaceGen' ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpWTlqRT.p.
% Please follow local copyright laws when handling this file.

