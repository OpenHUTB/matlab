function tf=isSimulinkArtifact(artifactName,artifactExt)
    if~isempty(artifactExt)
        tf=any(strcmpi(artifactExt,{'.slx','.mdl'}));
    else
        tf=(exist(artifactName,'file')==4);
    end
end
