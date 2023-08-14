function onCopyItem()






    currentReq=slreq.app.MainManager.getCurrentViewSelections();
    if isa(currentReq,'slreq.das.Requirement')
        slreq.app.CallbackHandler.copyItem(currentReq);
    end
end
