function restore( sourceModel, sourceBlock, RTWInfoBackup )





[ ~, enableMappingProperties ] = Simulink.CodeMapping.isCompatible( sourceModel, sourceBlock );
[ modelMapping, mappingType ] = Simulink.CodeMapping.getCurrentMapping( sourceModel );
SLPortName = get_param( sourceBlock, 'Name' );
modelName = get_param( sourceModel, 'Name' );
if enableMappingProperties
SLPortName = Simulink.CodeMapping.escapeSimulinkName( SLPortName );
InportMappingObj = modelMapping.Inports.findobj( 'Block', [ modelName, '/', SLPortName ] );
if ~isempty( InportMappingObj.MappedTo )
if strcmp( mappingType, 'AutosarTarget' )
InportMappingObj.mapPortElement( RTWInfoBackup.ARPortName, RTWInfoBackup.ARElementName, RTWInfoBackup.ARDataAccessMode );
end 
end 
if strcmp( mappingType, 'CoderDictionary' )
if ~RTWInfoBackup.HasCoderData
InportMappingObj.unmap(  );
else 
InportMappingObj.map( RTWInfoBackup.CoderData );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpL7dp3f.p.
% Please follow local copyright laws when handling this file.

