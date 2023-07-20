function sid=getSIDFromArtifact(artifact)








    if isnan(str2double(strrep(artifact.Address,':','')))
        [~,sid,~]=fileparts(artifact.Address);
    else
        [~,modelName,~]=fileparts(artifact.getSelfContainedArtifact().Address);
        sid=[modelName,':',artifact.Address];
    end
