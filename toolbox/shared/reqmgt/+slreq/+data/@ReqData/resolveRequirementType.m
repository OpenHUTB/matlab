function resolveRequirementType(this,mfReq)






    if reqmgt('rmiFeature','CppReqData')
        this.repository.resolveRequirementType(mfReq);
        return;
    end

    if isempty(mfReq.typeName)

        return;
    end

    mfReqType=this.repository.requirementTypes{mfReq.typeName};
    if isempty(mfReqType)



        typeName=mfReq.typeName;
        this.addCustomRequirementType(typeName,'Unset','');
    end
end
