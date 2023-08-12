function retVal = modelWorkspaceGetVariableHelper( mws, objectName, refForHandleObject )






if nargin < 3
refForHandleObject = false;
end 
if ~refForHandleObject


retVal = mws.getVariableCopy( objectName );
else 



previousFlag = mws.valueSourceErrorCheckingInCommandLineAPI;
mws.valueSourceErrorCheckingInCommandLineAPI = false;
retVal = mws.getVariable( objectName );
mws.valueSourceErrorCheckingInCommandLineAPI = previousFlag;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpKs2UOm.p.
% Please follow local copyright laws when handling this file.

