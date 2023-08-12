function out = getDefaultIOBlocksMode( hCS )





validateattributes( hCS, { 'Simulink.ConfigSet', 'Simulink.ConfigSetRef' }, { 'nonempty' } );
assert( hCS.isValidParam( 'CoderTargetData' ), 'No CoderTargetData' );

out = 'deployed';
targetHardwareInfo = codertarget.targethardware.getTargetHardware( hCS );
if ~isempty( targetHardwareInfo ) && isprop( targetHardwareInfo, 'DefaultIOBlocksMode' )
out = targetHardwareInfo.DefaultIOBlocksMode;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpkFrJ0C.p.
% Please follow local copyright laws when handling this file.

