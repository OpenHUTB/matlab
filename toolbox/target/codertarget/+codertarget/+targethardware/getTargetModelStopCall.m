function call = getTargetModelStopCall( hObj )





if isa( hObj, 'CoderTarget.SettingsController' )
hObj = hObj.getConfigSet(  );
elseif ischar( hObj )
hObj = getActiveConfigSet( hObj );
else 
assert( isa( hObj, 'Simulink.ConfigSet' ), [ mfilename, ' called with a wrong argument' ] );
end 

targetInfo = codertarget.attributes.getTargetHardwareAttributes( hObj );
call = targetInfo.getTargetModelStopCall(  );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpb27fjp.p.
% Please follow local copyright laws when handling this file.

