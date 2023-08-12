function validateCell = runIPCoreCodeGen( obj )


if obj.isIPCoreGen
validateCell = obj.hTurnkey.hCHandle.makehdlturnkey;
else 
error( message( 'hdlcommon:workflow:IPWorkflowOnly', 'runIPCoreCodeGen' ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmphGyI3P.p.
% Please follow local copyright laws when handling this file.

