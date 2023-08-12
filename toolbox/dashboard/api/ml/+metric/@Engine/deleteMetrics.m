function deleteMetrics( obj, metricIDs, NameValueArgs )




R36
obj
metricIDs{ mustBeText }
NameValueArgs.ArtifactScope{ mustBeText } = {  }
end 

metricIDs = convertCharsToStrings( metricIDs );
artifactScope = convertCharsToStrings( NameValueArgs.ArtifactScope );

artUUID = obj.getUUIDFromAddress( artifactScope, false );


rs = metric.internal.ResultService.get( obj.ProjectPath );

if isempty( artUUID )
rs.deleteMetricsInAllScopes( metricIDs );
else 
rs.deleteMetricsInScope( metricIDs, artUUID );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp_NIAaL.p.
% Please follow local copyright laws when handling this file.

