function reqSets=getReqSetsThatHaveCustomAttribute(this,attrName)







    reqSets=slreq.data.RequirementSet.empty();

    rSets=this.getLoadedReqSets();

    for n=1:length(rSets)
        mfReqSet=this.getModelObj(rSets(n));
        attr=mfReqSet.attributeRegistry{attrName};
        if~isempty(attr)

            reqSets(end+1)=rSets(n);%#ok<AGROW>
        end
    end
end
