function setCommunicationAttributesFromJSON( modelH, mappingCategory, blockPath, valuesJSON )




comSpecStruct = mls.internal.fromJSON( valuesJSON ).callbackinfo;


mm_internal = Simulink.CodeMapping.get( modelH, 'AutosarTarget' );
mappingObject = mm_internal.( mappingCategory ).findobj( 'Block', blockPath );
if ~isempty( mappingObject ) && ~isempty( comSpecStruct )
propNames = fieldnames( comSpecStruct );
ME = [  ];
for k = 1:numel( propNames )
propName = propNames{ k };
propValue = comSpecStruct.( propName );
try 
autosar.ui.comspec.ComSpecPropertyHandler.setComSpecPropertyValueForPropertyInspector(  ...
modelH, mappingObject, propName, propValue );
catch ME
end 
end 
if ~isempty( ME )
throw( ME );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpFOTvXK.p.
% Please follow local copyright laws when handling this file.

