function resolveRequirementTypesForReqSet(this,mfReqSet)

    if reqmgt('rmiFeature','CppReqData')
        this.repository.resolveRequirementTypes(mfReqSet);
        return;
    end

    reqs=mfReqSet.items.toArray;

    if isempty(mfReqSet.defaultTypeName)

        mfReqSet.defaultTypeName=slreq.custom.RequirementType.Functional.getTypeName;
        for n=1:length(reqs)
            req=reqs(n);
            if~isa(req,'slreq.datamodel.Justification')
                req.typeName=mfReqSet.defaultTypeName;
            end
        end
    end



    cached_stereotype={};
    for n=1:length(reqs)
        mfReq=reqs(n);
        if~isempty(mfReq.typeName)

            if any(strcmp(mfReq.typeName,cached_stereotype))

                continue;
            end

            [prName,sType,~]=slreq.internal.ProfileReqType.getProfileStereotype(mfReq.typeName);
            if~isempty(prName)&&~isempty(sType)

                cached_stereotype{end+1}=mfReq.typeName;
                continue;
            end
        end
        this.resolveRequirementType(mfReq);
    end
end
