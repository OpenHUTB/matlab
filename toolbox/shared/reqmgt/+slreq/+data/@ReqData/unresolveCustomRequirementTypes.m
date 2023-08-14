function unresolveCustomRequirementTypes(this)





    reqTypes=this.repository.requirementTypes.toArray;
    unsetType=this.getRequirementType('Unset');

    for n=1:length(reqTypes)
        reqType=reqTypes(n);
        if~reqType.isBuiltin&&reqType~=unsetType

            reqType.superType=unsetType;
            reqType.description='';
        end
    end
end