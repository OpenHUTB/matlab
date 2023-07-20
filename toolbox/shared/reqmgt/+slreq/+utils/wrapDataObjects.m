function apiObjects=wrapDataObjects(dataObjects)




    if isempty(dataObjects)
        apiObjects=[];
        return;
    end

    inType=class(dataObjects(1));
    switch inType
    case 'slreq.data.Requirement'
        if dataObjects(1).external
            apiObjects=slreq.Reference.empty();
        else
            apiObjects=slreq.Requirement.empty();
        end
    case 'slreq.data.RequirementSet'
        apiObjects=slreq.ReqSet.empty();
    case 'slreq.data.LinkSet'
        apiObjects=slreq.LinkSet.empty();
    case 'slreq.data.Link'
        apiObjects=slreq.Link.empty();
    otherwise
        error('Input of type %s is not supported',inType);
    end

    for i=1:numel(dataObjects)
        apiObjects(end+1)=slreq.utils.dataToApiObject(dataObjects(i));%#ok<AGROW>
    end
end
