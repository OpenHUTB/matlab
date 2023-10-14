function deleteMetrics( obj, metricIDs, NameValueArgs )

arguments
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


