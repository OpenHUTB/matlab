function call = getTargetHardwareInitializationCall( hObj )





if isa( hObj, 'CoderTarget.SettingsController' )
hObj = hObj.getConfigSet(  );
elseif ischar( hObj )
hObj = getActiveConfigSet( hObj );
else 
assert( isa( hObj, 'Simulink.ConfigSet' ), [ mfilename, ' called with a wrong argument' ] );
end 

targetInfo = codertarget.attributes.getTargetHardwareAttributes( hObj );
call = targetInfo.getTargetInitializationCalls(  );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpUuwJg8.p.
% Please follow local copyright laws when handling this file.

