








function propUpdated = setPerInstancePropertyForPort( modelH, portH,  ...
propertyName, propertyValue )

modelMapping = Simulink.CodeMapping.getCurrentMapping( modelH );
assert( isa( modelMapping, 'Simulink.CoderDictionary.ModelMapping' ) );

modelName = get_param( modelH, 'Name' );
parentBlock = get_param( portH, 'Parent' );
if isequal( get_param( parentBlock, 'BlockType' ), 'Inport' ) &&  ...
isequal( get_param( parentBlock, 'Parent' ), modelName )

elemMapping = modelMapping.Inports.findobj( 'Block', parentBlock );
else 

elemMapping = modelMapping.Signals.findobj( 'PortHandle', portH );
end 
assert( length( elemMapping ) == 1 )

propUpdated = Simulink.CodeMapping.setPerInstancePropertyValue(  ...
modelH, elemMapping, 'MappedTo', propertyName, propertyValue );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpSkCxwi.p.
% Please follow local copyright laws when handling this file.

