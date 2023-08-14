function[mwReqs,exReqs,justfItems]=getItems(this,reqSet)







    if~isa(reqSet,'slreq.data.RequirementSet')||~isvalid(reqSet)
        error('Invalid argument: expected slreq.data.RequirementSet');
    end

    mwReqs=slreq.data.Requirement.empty;
    exReqs=slreq.data.Requirement.empty;
    justfItems=slreq.data.Requirement.empty;

    modelReqSet=this.getModelObj(reqSet);
    if~isempty(modelReqSet)
        items=modelReqSet.items.toArray();
        numReqs=numel(items);
        for i=1:numReqs
            item=items(i);
            switch class(item)
            case 'slreq.datamodel.MwRequirement'
                mwReqs(end+1)=this.wrap(item);%#ok<AGROW>
            case 'slreq.datamodel.Justification'
                justfItems(end+1)=this.wrap(item);%#ok<AGROW>
            otherwise
                exReqs(end+1)=this.wrap(item);%#ok<AGROW>
            end
        end
    end
end
