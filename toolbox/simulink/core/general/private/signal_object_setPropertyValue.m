function signal_object_setPropertyValue( lineObj, prop, value )



assert( isa( lineObj, 'Simulink.Line' ) );
sigObj = lineObj.SignalObject;
if isempty( sigObj ) && lineObj.isValidProperty( prop )
lineObj.setPropValue( prop, value );
end 

if ~isempty( sigObj )
fullProp = signal_object_getFullPropertyName( sigObj, prop );
sigObj.setPropValue( fullProp, value );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmprGbsr9.p.
% Please follow local copyright laws when handling this file.

