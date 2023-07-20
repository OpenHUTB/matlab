
function saveReqSetAs(cbinfo)
    appmgr=slreq.app.MainManager.getInstance();
    if slreq.toolstrip.activateEditor(cbinfo)
        currentObj=appmgr.requirementsEditor.getCurrentSelection();
    else
        modelH=slreq.toolstrip.getModelHandle(cbinfo);
        spObj=appmgr.spreadsheetManager.getSpreadSheetObject(modelH);
        if~isempty(spObj)
            currentObj=spObj.getCurrentSelection;
        end
    end

    if~isempty(currentObj)
        appmgr.callbackHandler.saveReqLinkSet(currentObj,true);
    end
end