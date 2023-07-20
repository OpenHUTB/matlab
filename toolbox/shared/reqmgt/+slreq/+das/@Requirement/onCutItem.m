function onCutItem()






    currentReq=slreq.app.MainManager.getCurrentViewSelections();
    if isa(currentReq,'slreq.das.Requirement')
        slreq.app.CallbackHandler.cutItem(currentReq);
    end
end
