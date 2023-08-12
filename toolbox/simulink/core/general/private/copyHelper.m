function retVal = copyHelper( origVal )






w( 1 ) = warning( 'off', 'Simulink:Data:CopyWillNotPreserveCodeProps' );
w( 2 ) = warning( 'off', 'Simulink:modelReference:NormalModeSimulationWarning' );
restoreWarnings = onCleanup( @(  )warning( w ) );
retVal = copy( origVal );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpHKefI_.p.
% Please follow local copyright laws when handling this file.

