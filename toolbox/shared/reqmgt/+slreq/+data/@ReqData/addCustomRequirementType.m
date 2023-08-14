function mfReqType=addCustomRequirementType(this,name,superTypeNameOrEnum,description)




    if isenum(superTypeNameOrEnum)&&isa(superTypeNameOrEnum,'slreq.custom.RequirementType')

        superTypeNameOrEnum=char(superTypeNameOrEnum);
    end

    mfSuperType=this.repository.requirementTypes{superTypeNameOrEnum};
    if isempty(mfSuperType)
        error(message('Slvnv:slreq:InvalidSuperTypeNameNotFound',superTypeNameOrEnum));
    elseif slreq.app.RequirementTypeManager.isUnresolved(mfSuperType)
        error(message('Slvnv:slreq:InvalidSuperTypeUnresolved',superTypeNameOrEnum))
    end

    existingRequirementType=this.repository.requirementTypes{name};
    if~isempty(existingRequirementType)
        if slreq.app.RequirementTypeManager.isUnresolved(existingRequirementType)



            mfReqType=existingRequirementType;
        else
            error(message('Slvnv:slreq:SpecifiedTypeExists',name));
        end
    else

        mfReqType=slreq.datamodel.RequirementType(this.model);
        mfReqType.name=name;
        this.repository.requirementTypes.add(mfReqType);
    end

    mfReqType.isBuiltin=false;

    mfReqType.description=description;


    mfReqType.superType=mfSuperType;

end