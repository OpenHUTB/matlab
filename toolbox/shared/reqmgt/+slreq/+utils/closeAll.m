function closeAll(isForce)









    if slreq.internal.isSharedSlreqInstalled()



        linkSetMgr=slreq.linkmgr.LinkSetManager.getInstance();
        linkSetMgr.setIncomingLinksLoading(false);
    end
    if slreq.app.MainManager.exists()
        mgr=slreq.app.MainManager.getInstance;
        mgr.putToSleep();
    end





    linkSets=slreq.data.ReqData.getInstance.getLoadedLinkSets();
    for i=1:numel(linkSets)
        linkSet=linkSets(i);
        if~isempty(linkSet)
            if linkSet.dirty
                if~isForce
                    if rmiml.promptToSave(linkSet.filepath,'')
                        linkSet.save();
                    end
                end



                linkSet.discard();
            end
        end
    end


    reqSets=slreq.data.ReqData.getInstance.getLoadedReqSets();
    for i=1:numel(reqSets)
        rset=reqSets(i);
        if~isForce
            if rset.dirty
                slreq.utils.closeReqSet(rset,true);
            end
        else



        end
    end

end
