function enabled = signal_object_isPropertyEnabled( lineObj, prop )



enabled = false;
assert( isa( lineObj, 'Simulink.Line' ) );
sigObj = lineObj.SignalObject;
if isempty( sigObj ) && lineObj.isValidProperty( prop )
enabled = ~lineObj.isReadonlyProperty( prop );
end 

if ~isempty( sigObj )
fullProp = signal_object_getFullPropertyName( sigObj, prop );
enabled = ~sigObj.isReadonlyProperty( fullProp );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpCsOmnZ.p.
% Please follow local copyright laws when handling this file.

