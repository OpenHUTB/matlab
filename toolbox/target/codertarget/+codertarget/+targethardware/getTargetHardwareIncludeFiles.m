function call = getTargetHardwareIncludeFiles( hObj )






try 
if isa( hObj, 'CoderTarget.SettingsController' )
hObj = hObj.getConfigSet(  );
elseif ischar( hObj )
hObj = getActiveConfigSet( hObj );
else 
assert( isa( hObj, 'Simulink.ConfigSet' ), [ mfilename, ' called with a wrong argument' ] );
end 
attributeInfo = codertarget.attributes.getTargetHardwareAttributes( hObj );
call2 = regexprep( codertarget.utils.replaceTokens( hObj, attributeInfo.getIncludeFiles(  ) ), '\\', '/' );


schedulerInfo = codertarget.scheduler.getTargetHardwareScheduler( hObj );
if ~isempty( schedulerInfo )
call1 = regexprep( codertarget.utils.replaceTokens( hObj, schedulerInfo.getIncludeFiles(  ) ), '\\', '/' );
else 
call1 = '';
end 

call = [ call2, call1 ];
catch ex
warning( ex.identifier, ex.message );
call = '';
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp0DzUy6.p.
% Please follow local copyright laws when handling this file.

