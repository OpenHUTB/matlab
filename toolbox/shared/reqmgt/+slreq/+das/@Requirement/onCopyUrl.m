function onCopyUrl()





    currentReq=slreq.app.MainManager.getCurrentViewSelections();

    if~isempty(currentReq)&&isa(currentReq,'slreq.das.Requirement')

        [adapter,artifact,id]=currentReq.dataModelObj.getAdapter();
        url=adapter.getURL(artifact,id);
        clipboard('copy',url);

    end

end
