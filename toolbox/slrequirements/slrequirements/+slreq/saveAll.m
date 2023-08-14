










function count=saveAll()

    count=0;

    reqSets=slreq.data.ReqData.getInstance.getLoadedReqSets();
    for i=1:numel(reqSets)

        if~slreq.internal.LinkUtil.isEmbeddedReqSet(reqSets(i))
            count=count+reqSets(i).save();
        end
    end

    linkSets=slreq.data.ReqData.getInstance.getLoadedLinkSets();
    for i=1:numel(linkSets)
        count=count+linkSets(i).save();
    end

end

