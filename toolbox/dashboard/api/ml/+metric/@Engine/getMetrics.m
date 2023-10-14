function res = getMetrics( obj, metricIDs, NameValueArgs )

arguments
    obj
    metricIDs{ mustBeText }
    NameValueArgs.ArtifactScope{ mustBeText } = {  }
end

metricIDs = convertCharsToStrings( metricIDs );
artifactScope = convertCharsToStrings( NameValueArgs.ArtifactScope );

res = metric.Result.empty(  );
if numel( artifactScope ) == 1 && alm.internal.uuid.isUuid( artifactScope )
    artUUID = artifactScope;
else
    artUUID = obj.getUUIDFromAddress( artifactScope, false );
end


rs = metric.internal.ResultService.get( obj.ProjectPath );
as = alm.internal.ArtifactService.get( obj.ProjectPath );



model_R = mf.zero.Model(  );

for idx = 1:length( metricIDs )

    metricID = metricIDs( idx );



    if ~isempty( metricID )


        if isempty( artUUID )
            mf_res = rs.getMetricsInAllScopes( metricID );
        else
            mf_res = rs.getMetricsInScope( metricID, artUUID );
        end
    end




    for iRes = 1:numel( mf_res )


        mf_res_R = mf_res( iRes ).copy( model_R );


        for iRef = 1:mf_res( iRes ).Artifacts.Size
            mf_aref = mf_res( iRes ).Artifacts( iRef );
            mf_aref_R = mergeArtifactReference( model_R, mf_aref );
            mf_res_R.Artifacts.add( mf_aref_R );
        end



        if isempty( model_R.findElement( mf_res_R.ScopeUuid ) )
            art = as.getGraph(  ).getArtifactByUuid( mf_res_R.ScopeUuid );
            if ~isempty( art )
                metric.internal.createArtifactReference( model_R, art );
            end
        end

        res( end  + 1 ) = metric.Result( mf_res_R );%#ok<AGROW>

    end


end
end


function mf_aref_R = mergeArtifactReference( model_R, mf_aref )
mf_aref_R = model_R.findElement( mf_aref.UUID );
if isempty( mf_aref_R )
    mf_aref_R = mf_aref.copy( model_R, true );
else

end
end

