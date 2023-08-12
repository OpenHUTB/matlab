




function [ clr, isLocked ] = unlockModel( model )

clr = onCleanup.empty;
model = bdroot( model );
isLocked = strcmpi( get_param( model, 'Lock' ), 'on' );
if isLocked && ~bdIsLibrary( model )
Simulink.harness.internal.setBDLock( model, false )
clr = onCleanup( @(  )Simulink.harness.internal.setBDLock( model, true ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpQmSABO.p.
% Please follow local copyright laws when handling this file.

