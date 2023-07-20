function changed=refreshLinkSetsByRegistration(this,reqSetName)









    changed=false;

    if~contains(reqSetName,'.slreqx')
        reqSetName=[reqSetName,'.slreqx'];
    end
    if slreq.internal.isSharedSlreqInstalled()


        linkSetUpdateMgr=slreq.linkmgr.LinkSetUpdateMgr.getInstance();

        allLinkSets=this.getLoadedLinkSets;
        for idx=1:length(allLinkSets)
            linkSet=allLinkSets(idx);
            dependeeReqSets=linkSet.getRegisteredRequirementSets();
            if any(contains(dependeeReqSets,reqSetName))






                changed=changed|linkSetUpdateMgr.requestUpdate(linkSet,false,false);
            end
        end
    end

end
