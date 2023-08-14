function apiObject=dataToApiObject(dataObject)

    switch class(dataObject)

    case 'slreq.data.RequirementSet'
        apiObject=slreq.ReqSet(dataObject);

    case 'slreq.data.LinkSet'
        apiObject=slreq.LinkSet(dataObject);

    case 'slreq.data.Requirement'
        if dataObject.external
            apiObject=slreq.Reference(dataObject);
        elseif dataObject.isJustification
            apiObject=slreq.Justification(dataObject);
        else
            apiObject=slreq.Requirement(dataObject);
        end

    case 'slreq.data.Link'
        apiObject=slreq.Link(dataObject);

    otherwise
        error('unsupported type: %s',class(dataObject));
    end
end