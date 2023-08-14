function refreshUIOnArtifactLoad(this,artifact)





    dasLinkSets=this.linkRoot.children;
    for n=1:length(dasLinkSets)
        if strcmp(dasLinkSets(n).Artifact,artifact)



            this.update(true);
            return;
        end
    end

    linkmgr=slreq.linkmgr.LinkSetManager.getInstance();
    if isempty(linkmgr.lsmHandler)
        return;
    end

    [artifactDomain,artifactName]=slreq.utils.getDomainLabel(artifact);
    linksetsWithDest=linkmgr.lsmHandler.getReferencedLinksets(artifactName,artifactDomain);
    if~isempty(linksetsWithDest)
        this.update(true);
        return;
    end
end
