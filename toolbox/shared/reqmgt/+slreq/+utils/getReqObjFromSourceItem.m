function reqObj=getReqObjFromSourceItem(sourceItem)






    if~(isstruct(sourceItem)||isa(sourceItem,'slreq.data.SourceItem'))...
        ||~strcmp(sourceItem.domain,'linktype_rmi_slreq')
        error('SLReq:Utils:getReqObjFromSourceItem:InvalidSouceType',...
        'Invalid souce type specified');
    end


    reqObj=slreq.data.Requirement.empty;

    reqSet=slreq.data.ReqData.getInstance.getReqSet(sourceItem.artifactUri);
    if~isempty(reqSet)
        reqObj=reqSet.getRequirementById(sourceItem.id);
    end
end
