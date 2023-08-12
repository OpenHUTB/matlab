











function [ paramToParamMap, paramDirectUsersMap, paramVarUsageMap, paramsAffectedByParamMap, directUsersParamMap, indirectUsersParamMap ] = generateParamDataStructures( model, parametersToConsider )

R36
model( 1, : )char
parametersToConsider( :, : ) = [  ]
end 
import slslicer.internal.ParameterDependenceInfo.*;

if ~bdIsLoaded( model )
load_system( model );
end 

if isempty( parametersToConsider )


try 

varUsage = Simulink.findVars( model, 'SearchMethod', 'cached', 'IncludeEnumTypes', 'on', 'SearchReferencedModels', 'on' );
catch 
varUsage = Simulink.findVars( model, 'IncludeEnumTypes', 'on', 'SearchReferencedModels', 'on' );
end 
[ paramToParamMap, paramDirectUsersMap, paramVarUsageMap, paramsAffectedByParamMap, directUsersParamMap, indirectUsersParamMap, ~ ] = generateParamMaps( varUsage );
else 






varUsages = getPopulatedVarUsages( model, parametersToConsider );
[ paramToParamMap, paramDirectUsersMap, paramVarUsageMap, paramsAffectedByParamMap, directUsersParamMap, indirectUsersParamMap, indirectParams ] = generateParamMaps( varUsages );


if ~isempty( indirectParams )
indirectVarUsages = [  ];
keysDirectParams = keys( paramToParamMap );


for idx = 1:length( indirectParams )

paramKey = getParamMapKey( indirectParams( idx ) );
if ~any( strcmp( keysDirectParams, paramKey ) )



actualSource = getActualSource( indirectParams( idx ).Source );
try 


varUsageInstance = Simulink.findVars( model, 'SearchReferencedModels', 'on', 'SearchMethod', 'cached', 'SourceType', indirectParams( idx ).SourceType, 'Source', actualSource, 'Name', indirectParams( idx ).Name );
catch 
varUsageInstance = Simulink.findVars( model, 'SearchReferencedModels', 'on', 'SourceType', indirectParams( idx ).SourceType, 'Source', actualSource, 'Name', indirectParams( idx ).Name );
end 
indirectVarUsages = [ indirectVarUsages, varUsageInstance ];
end 
end 





[ paramToParamMapIndirect, paramDirectUsersMapIndirect, paramVarUsageMapIndirect, paramsAffectedByParamMapIndirect, directUsersParamMapIndirect, indirectUsersParamMapIndirect ] = generateParamDataStructures( model, indirectVarUsages );

paramToParamMap = mergeMaps( paramToParamMap, paramToParamMapIndirect );
paramDirectUsersMap = mergeMaps( paramDirectUsersMap, paramDirectUsersMapIndirect );
paramVarUsageMap = [ paramVarUsageMap;paramVarUsageMapIndirect ];
paramsAffectedByParamMap = mergeMaps( paramsAffectedByParamMap, paramsAffectedByParamMapIndirect );
directUsersParamMap = mergeMaps( directUsersParamMap, directUsersParamMapIndirect );
indirectUsersParamMap = mergeMaps( indirectUsersParamMap, indirectUsersParamMapIndirect );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpeB2LuQ.p.
% Please follow local copyright laws when handling this file.

