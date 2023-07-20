



















function wasSaved=close(artifactPath)

    wasSaved=false;

    artifactPath=convertStringsToChars(artifactPath);

    if slreq.hasData(artifactPath)
        if slreq.hasChanges(artifactPath)
            if slreq.utils.promptToSave(artifactPath)
                linkSetFile=slreq.saveLinks(artifactPath);
                wasSaved=~isempty(linkSetFile);
            end
        end
        slreq.discardLinkSet(artifactPath);
    end

end