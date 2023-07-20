function clearChangeIssues(linkUUIDList,userComment)
    linkUUIDList=unique(linkUUIDList);










    appmgr=slreq.app.MainManager.getInstance;
    appmgr.notify('SleepUI');
    clp=onCleanup(@()postUpdate(appmgr));







    ct=slreq.analysis.ChangeTracker;
    reqData=slreq.data.ReqData.getInstance();

    for index=1:length(linkUUIDList)

        uuid=linkUUIDList{index};
        dataLink=reqData.findObject(uuid);

        if~isempty(dataLink)

            if(dataLink.sourceChangeStatus.isFail)
                ct.clearLinkedSourceIssues(dataLink,userComment);
            end

            if(dataLink.destinationChangeStatus.isFail)
                ct.clearLinkedDestinationIssues(dataLink,userComment);
            end

        end
    end
end
function postUpdate(appmgr)
    appmgr.notify('WakeUI')
    appmgr.changeTracker.updateViews();
end