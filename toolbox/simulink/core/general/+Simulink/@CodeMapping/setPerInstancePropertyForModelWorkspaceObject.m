








function propUpdated = setPerInstancePropertyForModelWorkspaceObject( modelH, uuid,  ...
propertyName, propertyValue )

modelMapping = Simulink.CodeMapping.getCurrentMapping( modelH );
assert( isa( modelMapping, 'Simulink.CoderDictionary.ModelMapping' ) );

elemMapping = modelMapping.ModelScopedParameters.findobj( 'UUID', uuid );
if isempty( elemMapping )
elemMapping = modelMapping.SynthesizedLocalDataStores.findobj( 'UUID', uuid );
end 
assert( length( elemMapping ) == 1 )

propUpdated = Simulink.CodeMapping.setPerInstancePropertyValue(  ...
modelH, elemMapping, 'MappedTo', propertyName, propertyValue );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3v3bCP.p.
% Please follow local copyright laws when handling this file.

