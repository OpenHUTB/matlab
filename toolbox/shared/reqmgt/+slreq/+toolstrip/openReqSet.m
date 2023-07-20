


function openReqSet(cbinfo)

    appmgr=slreq.app.MainManager.getInstance();
    appmgr.notify('SleepUI');
    cleanup=onCleanup(@()appmgr.notify('WakeUI'));

    if slreq.toolstrip.activateEditor(cbinfo)
        modelH=-1;
    else
        modelH=slreq.toolstrip.getModelHandle(cbinfo);
    end

    reqSetDas=appmgr.callbackHandler.openReqSet(cbinfo);
    if isempty(reqSetDas)

        return;
    end


    currentView=appmgr.getSpreadSheetObject(modelH);

    if isa(currentView,'slreq.gui.ReqSpreadSheet')
        appmgr.setLastOperatedView(currentView);

        currentView.createAndRegisterLinkSet(reqSetDas);
        currentView.update();
    end


    appmgr.notify('WakeUI');
    if~isempty(currentView)
        currentView.setSelectedObject(reqSetDas);
    end
end
