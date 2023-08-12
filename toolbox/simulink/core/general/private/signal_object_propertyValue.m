function value = signal_object_propertyValue( lineObj, prop )



assert( isa( lineObj, 'Simulink.Line' ) );
sigObj = lineObj.SignalObject;
if isempty( sigObj ) && lineObj.isValidProperty( prop )
value = lineObj.getPropValue( prop );
end 

if ~isempty( sigObj )
fullProp = signal_object_getFullPropertyName( sigObj, prop );
value = sigObj.getPropValue( fullProp );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpdLtAbq.p.
% Please follow local copyright laws when handling this file.

