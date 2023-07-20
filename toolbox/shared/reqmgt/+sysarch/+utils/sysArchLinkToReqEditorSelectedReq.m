function sysArchLinkToReqEditorSelectedReq(modelName,diagElemUUID)








    curHlgtedComp=sysarch.getSemanticElementFromDiagram(modelName,diagElemUUID);
    elemToLink=sysarch.getLinkableObjectFromViewObject(curHlgtedComp);
    if sysarch.isLinkableCompositionElement(elemToLink)
        elemToLink=systemcomposer.utils.getSimulinkPeer(elemToLink);
    end


















    reqMgr=slreq.app.MainManager.getInstance;



    view=reqMgr.getCurrentView();

    if isempty(view)
        error('systemcomposer:Requirements:NoRequirementSelected',message('SystemArchitecture:Requirements:NoRequirementSelected').getString);
    end


    dasReqs=view.getCurrentSelection;

    if~isa(dasReqs,'slreq.das.Requirement')
        error('systemcomposer:Requirements:NoRequirementSelected',message('SystemArchitecture:Requirements:NoRequirementSelected').getString);
    end







    linkInfo=slreq.utils.getRmiStruct(elemToLink);
    arrayfun(@(x)x.addLink(linkInfo),dasReqs);
end


