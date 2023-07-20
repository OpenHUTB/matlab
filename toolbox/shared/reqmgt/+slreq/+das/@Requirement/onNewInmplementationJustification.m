function onNewInmplementationJustification()






    currentReq=slreq.app.MainManager.getCurrentViewSelections();
    if isa(currentReq,'slreq.das.Requirement')
        currentReq.view.callbackHandler.addJustificationAndLink(currentReq,'Implement');
    end
end
