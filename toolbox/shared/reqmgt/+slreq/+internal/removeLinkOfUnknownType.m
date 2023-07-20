function removeLinkOfUnknownType(mfLinkSet,mfLink)


























    reqData=slreq.data.ReqData.getInstance();
    dataLink=reqData.wrap(mfLink);



    src=mfLink.source;
    dest=mfLink.dest;
    rmiut.warnNoBacktrace('Slvnv:slreq:RemoveLinkOfUnknownType',src.id,[dest.artifactUri,':',dest.artifactId]);

    mfLinkSet.links.remove(mfLink);
    mfLink.destroy;
    dataLink.delete;
    mfLinkSet.dirty=true;
end
