function changed=resolveReferences(this,mfLinkSet,loadReferencedReqsets)






    if nargin<3

        loadReferencedReqsets=true;
    end
    changed=false;

    dataLinkSet=this.wrap(mfLinkSet);
    linkSetArtifact=mfLinkSet.artifactUri;


    if loadReferencedReqsets
        regReqSetNames=dataLinkSet.getRegisteredRequirementSets();
        for n=1:length(regReqSetNames)



            regReqSetName=regReqSetNames{n};
            [storeUri,embeddedReqSet]=slreq.internal.LinkUtil.extractArtifactUri(regReqSetName);
            this.locateRequirementSet(storeUri,linkSetArtifact,loadReferencedReqsets,embeddedReqSet);
        end
    end

    changed=changed|mfLinkSet.resolveLinkDestinations(loadReferencedReqsets);
end

