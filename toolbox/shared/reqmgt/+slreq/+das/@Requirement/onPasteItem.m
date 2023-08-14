function onPasteItem()






    currentReq=slreq.app.MainManager.getCurrentViewSelections();
    if isa(currentReq,'slreq.das.Requirement')
        slreq.app.CallbackHandler.pasteItem(currentReq);
    end
end
