function propUpdated = setPerInstancePropertyValue( model, mappingObj, member, propName, propValue )




obj = mappingObj.( member );
isPropertyWithCalibrationEffect = false;
if isa( obj, 'Simulink.DataReferenceClass' )
attributesObj = obj.CSCAttributes;
storageClassAttribs = true;
elseif isa( obj, 'Simulink.AutosarTarget.DictionaryReference' )
attributesObj = obj.PerInstanceProperties;
storageClassAttribs = false;



isPropertyWithCalibrationEffect =  ...
strcmp( obj.ArDataRole, 'PortParameter' );
if isPropertyWithCalibrationEffect

m3iDataElement =  ...
autosar.mm.util.findM3iDataElementFromPortParameterMapping( model, mappingObj );
if ~isempty( m3iDataElement )



autosar.api.getAUTOSARProperties.errorOutIfReadOnlyObject( m3iDataElement );
end 
end 
end 

propUpdated = false;
if ~isempty( obj )
encodedString = '';
if ~isempty( attributesObj )
records = jsondecode( attributesObj );
entryFound = false;
for ii = 1:numel( records )
if strcmp( records( ii ).Name, propName )
records( ii ).Value = propValue;
entryFound = true;
break ;
end 
end 
if ~entryFound
records( end  + 1 ) = struct( 'Name', propName, 'Value', '' );
records( end  ).Value = propValue;
end 


indicesToRemove = [  ];
for ii = 1:numel( records )
if storageClassAttribs
defaultVal = obj.getCSCAttributeDefaultValue( model, records( ii ).Name );
else 
isVariable = isa( mappingObj, 'Simulink.AutosarTarget.InternalDataMapping' );
defaultVal = obj.getPerInstancePropertyDefaultValue( records( ii ).Name, isVariable );
end 
if strcmp( records( ii ).Value, defaultVal )
indicesToRemove = [ indicesToRemove, ii ];%#ok<AGROW>
end 
end 
if numel( indicesToRemove ) > 0
records( indicesToRemove ) = [  ];
end 
if ~isempty( records )
encodedString = jsonencode( records );
end 

else 
if storageClassAttribs
defaultVal = obj.getCSCAttributeDefaultValue( model, propName );
else 
isVariable = isa( mappingObj, 'Simulink.AutosarTarget.InternalDataMapping' );
defaultVal = obj.getPerInstancePropertyDefaultValue( propName, isVariable );
end 
if ~strcmp( propValue, defaultVal )
encodedString = jsonencode( struct( 'Name', propName, 'Value', propValue ) );
end 
end 
propUpdated = true;
if storageClassAttribs
if isa( mappingObj, 'Simulink.CoderDictionary.DefaultsMapping' )
obj.CSCAttributes = encodedString;
else 
mappingObj.setCSCAttributes( encodedString );
end 
else 
mappingObj.setPerInstanceProperties( encodedString );
end 
set_param( model, 'Dirty', 'on' );
if isPropertyWithCalibrationEffect
autosar.mm.util.syncCalibrationProperties( model, mappingObj, propName );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpXq0P61.p.
% Please follow local copyright laws when handling this file.

