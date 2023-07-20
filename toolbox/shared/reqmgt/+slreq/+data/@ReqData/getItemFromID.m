function req=getItemFromID(this,reqSet,sid)







    req=[];

    if~isa(reqSet,'slreq.data.RequirementSet')||~isvalid(reqSet)
        error('Invalid argument: expected slreq.data.RequirementSet');
    end

    modelReqSet=this.getModelObj(reqSet);
    if~isempty(modelReqSet)
        sid=int32(str2double(sid));
        cItem=modelReqSet.items{sid};
        if~isempty(cItem)
            req=this.wrap(cItem);
        end
    end
end
