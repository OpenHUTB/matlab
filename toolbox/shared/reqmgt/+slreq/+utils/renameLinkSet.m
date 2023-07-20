function affectedSourceItems=renameLinkSet(oldArtifactPath,newArtifactPath)



    r=slreq.data.ReqData.getInstance;
    linkSet=r.getLinkSet(oldArtifactPath);

    if isempty(linkSet)
        affectedSourceItems=[];
        return;
    end

    affectedSourceItems=linkSet.moveArtifact(newArtifactPath);

end
