function reqSetObjs=getLoadedReqSets(this)






    reqSetObjs=slreq.data.RequirementSet.empty;

    if isempty(this.repository)
        return;
    end

    reqSets=this.repository.requirementSets.toArray;
    for i=1:length(reqSets)
        if~any(strcmp(reqSets(i).filepath,{'default.slreqx','clipboard.slreqx','slinternal_scratchpad.slreqx'}))
            reqSetObjs(end+1)=this.wrap(reqSets(i));%#ok<AGROW>
        end
    end
end
