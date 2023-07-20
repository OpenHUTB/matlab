function onLinkToSelectedSafetyManagerElement()
    dasReqs=slreq.app.MainManager.getCurrentViewSelections();
    if~isa(dasReqs,'slreq.das.Requirement')
        return;
    end

    req=rmism.selectionLink('',false);
    if isempty(req)
        return;
    end
    arrayfun(@(x)x.addLink(req),dasReqs);
end