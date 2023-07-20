function mfReqTypes=getAllRequirementTypes(this)





    mfReqTypes=this.repository.requirementTypes.toArray;

    UnsetType=this.repository.requirementTypes{'Unset'};
    mfReqTypes(mfReqTypes==UnsetType)=[];
end