function mfReqType=getRequirementType(this,typeNameOrEnum)






    if isa(typeNameOrEnum,'slreq.custom.RequirementType')&&isenum(typeNameOrEnum)

        typeName=typeNameOrEnum.getTypeName;
    elseif ischar(typeNameOrEnum)
        typeName=typeNameOrEnum;
    else
        assert(false,'Invalid input specified')
    end

    mfReqType=this.repository.requirementTypes{typeName};
    if isempty(mfReqType)
        error(message('Slvnv:slreq:InvalidReqTypeName',typeName));
    end
end
