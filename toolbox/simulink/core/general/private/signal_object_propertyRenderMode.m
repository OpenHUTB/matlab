function renderMode = signal_object_propertyRenderMode( lineObj, prop )



renderMode = 'RenderAsText';
dataType = 'unknown';

assert( isa( lineObj, 'Simulink.Line' ) );
sigObj = lineObj.SignalObject;
if isempty( sigObj ) && lineObj.isValidProperty( prop )
dataType = lineObj.getPropDataType( prop );
end 

if ~isempty( sigObj )
fullProp = signal_object_getFullPropertyName( sigObj, prop );
dataType = sigObj.getPropDataType( fullProp );
end 

if strcmp( dataType, 'bool' )
renderMode = 'RenderAsCheckBox';
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpKFohI8.p.
% Please follow local copyright laws when handling this file.

