








function propUpdated = setPerInstancePropertyForStateOrDSM( modelH, blockH,  ...
propertyName, propertyValue )

modelMapping = Simulink.CodeMapping.getCurrentMapping( modelH );
assert( isa( modelMapping, 'Simulink.CoderDictionary.ModelMapping' ) );

if isequal( get_param( blockH, 'BlockType' ), 'DataStoreMemory' )

elemMapping = modelMapping.DataStores.findobj( 'OwnerBlockHandle', blockH );
else 

elemMapping = modelMapping.States.findobj( 'OwnerBlockHandle', blockH );
end 

assert( length( elemMapping ) == 1 )

propUpdated = Simulink.CodeMapping.setPerInstancePropertyValue(  ...
modelH, elemMapping, 'MappedTo', propertyName, propertyValue );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpIN4bfc.p.
% Please follow local copyright laws when handling this file.

