function wasSaved=promptToSave(modelH)

    wasSaved=false;
    artifactPath=slreq.resolveArtifactPath(modelH,'linktype_rmi_simulink');
    if~isempty(artifactPath)
        if slreq.utils.promptToSave(artifactPath)
            linkSetFile=slreq.saveLinks(artifactPath);
            wasSaved=~isempty(linkSetFile);
        end
    end

end

