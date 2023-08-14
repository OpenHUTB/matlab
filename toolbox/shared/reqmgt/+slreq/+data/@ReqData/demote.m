function result=demote(this,req)





    slreq.utils.assertValid(req);

    if~isa(req,'slreq.data.Requirement')
        error('Invalid input: expected slreq.data.Requirement');
    end

    modelReq=req.getModelObj();
    modelReqSet=modelReq.requirementSet;
    sibling=this.findSibling(modelReq);

    if isempty(sibling)
        error(message('Slvnv:slreq:ErrorForDemote',req.id));
    elseif isa(sibling,'slreq.datamodel.ExternalRequirement')
        error(message('Slvnv:slreq:DemoteErrorOnExternalRequirement'));
    elseif isempty(modelReq.parent)&&isa(modelReq,'slreq.datamodel.Justification')

        error(message('Slvnv:slreq:ErrorForDemoteJustification',req.id))
    end

    if isempty(sibling)
        result=false;
    else

        req.parent=this.wrap(sibling);

        result=true;
    end
end
