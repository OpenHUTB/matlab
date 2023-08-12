function mappingObj = getCodeMappingObj( bdHandle, mappingTarget, modelElementType, modelElementName )
mappingObj = [  ];
model = bdroot( bdHandle );
[ modelMapping, mappingType ] = Simulink.CodeMapping.getCurrentMapping( model );
if ~isempty( modelMapping ) && strcmp( mappingType, mappingTarget )
dataMap = modelMapping.( modelElementType );
if ~isempty( dataMap )
mappingObj = dataMap.findobj( 'Parameter', modelElementName );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpAMqUJ7.p.
% Please follow local copyright laws when handling this file.

