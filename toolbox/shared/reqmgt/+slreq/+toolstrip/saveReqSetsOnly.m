
function saveReqSetsOnly(cbinfo)

    if slreq.toolstrip.activateEditor(cbinfo)
        modelH=-1;
    else
        modelH=slreq.toolstrip.getModelHandle(cbinfo);
    end

    appmgr=slreq.app.MainManager.getInstance();
    spObj=appmgr.spreadsheetManager.getSpreadSheetObject(modelH);
    currentObj=[];
    if~isempty(spObj)
        currentObj=spObj.getCurrentSelection;
    end

    appmgr.callbackHandler.saveAllReqSets(currentObj,false);
end