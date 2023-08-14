function onLinkToSelectedZCElement()



    [zcObjs,diagElem]=sysarch.getCurrentSelection();

    if isempty(zcObjs)

        return;
    end

    appmgr=slreq.app.MainManager.getInstance();

    appmgr.notify('SleepUI');
    clp=onCleanup(@()postUpdate(appmgr));

    modelName=sysarch.getBDRoot(zcObjs{1}.getZCIdentifier);
    for i=1:numel(diagElem)
        sysarch.utils.sysArchLinkToReqEditorSelectedReq(modelName,diagElem{i}.UUID);
    end
end

function postUpdate(appmgr)
    appmgr.notify('WakeUI')
    appmgr.update();
end