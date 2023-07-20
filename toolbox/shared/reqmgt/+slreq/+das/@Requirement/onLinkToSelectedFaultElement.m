function onLinkToSelectedFaultElement()
    dasReqs=slreq.app.MainManager.getCurrentViewSelections();
    if~isa(dasReqs,'slreq.das.Requirement')
        return;
    end

    req=rmifa.selectionLink('',false);
    if isempty(req)
        return;
    end
    srcInfo=slreq.utils.getRmiStruct(req);
    arrayfun(@(x)x.addLink(srcInfo),dasReqs);
end