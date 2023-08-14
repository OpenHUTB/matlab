function onCompleteSelectionLinking()





    appmgr=slreq.app.MainManager.getInstance();
    currentReqs=slreq.app.MainManager.getCurrentViewSelections();

    if isempty(currentReqs)||~isa(currentReqs,'slreq.das.Requirement')
        return;
    end
    appmgr.notify('SleepUI');
    clp2=onCleanup(@()postUpdate(appmgr));
    arrayfun(@(x)x.addLink(appmgr.linkTargetReqObject),currentReqs);
end

function postUpdate(appmgr)
    appmgr.notify('WakeUI')
    appmgr.update();
end