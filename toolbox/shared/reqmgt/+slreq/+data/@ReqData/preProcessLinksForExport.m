



function out=preProcessLinksForExport(this,dataReqSet)






    out=true;

    mfReqSet=dataReqSet.getModelObj();

    allReqs=mfReqSet.items.toArray();
    for i=1:length(allReqs)
        req=allReqs(i);

        refs=req.references.toArray();
        for j=1:length(refs)
            ref=refs(j);
            mfLink=ref.link;
            setLinkSrcDstSummary(mfLink);
        end
    end



    artifact=dataReqSet.filepath;
    domain='linktype_rmi_slreq';

    dataLinkSet=this.getLinkSet(artifact,domain);
    if~isempty(dataLinkSet)
        mfLinkSet=dataLinkSet.getModelObj();
        if~isempty(mfLinkSet)
            mfItems=mfLinkSet.items.toArray();
            for i=1:length(mfItems)
                mfLinks=mfItems(i).outgoingLinks.toArray();
                for j=1:length(mfLinks)
                    setLinkSrcDstSummary(mfLinks(j));
                end
            end
        end
    end

    function setLinkSrcDstSummary(mfLink)
        dataLink=this.wrap(mfLink);
        mfLinkSrc=mfLink.source;
        mfLinkDst=mfLink.dest;








        [srcAdapter,srcArtifactUri,srcArtifactId]=dataLink.getSrcAdapter();
        linkSrcSummary=srcAdapter.getSummary(srcArtifactUri,srcArtifactId);
        linkSrcUrl=srcAdapter.getURL(srcArtifactUri,srcArtifactId);

        [destAdapter,destArtifactUri,destArtifactId]=dataLink.getDestAdapter();
        linkDstSummary=destAdapter.getSummary(destArtifactUri,destArtifactId);
        linkDestUrl=destAdapter.getURL(destArtifactUri,destArtifactId);




        mfLinkSrc.summary=linkSrcSummary;
        mfLinkSrc.url=linkSrcUrl;







        mfLinkDst.summary=linkDstSummary;
        mfLinkDst.url=linkDestUrl;

    end
end

