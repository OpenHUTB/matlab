function updateLinkDestinationToProxy(this,dataLink,dataProxyReq)










    mfReq=this.getModelObj(dataProxyReq);
    if~isa(mfReq,'slreq.datamodel.ExternalRequirement')

        error('updateLinkDestintionToProxy() called for target of type %s',class(mfReq));
    end


    mfLink=this.getModelObj(dataLink);
    refPath=mfLink.source.artifact.artifactUri;
    mfLink.dest=this.createReferenceToReq(mfReq,refPath);
    dataLink.setDirty(true);
end

