function onNewVerificationJustification()






    currentReq=slreq.app.MainManager.getCurrentViewSelections();
    if isa(currentReq,'slreq.das.Requirement')
        currentReq.view.callbackHandler.addJustificationAndLink(currentReq,'Verify');
    end
end
