function addBuiltinRequirementTypes(this)






    mfUnset=addRequirementType(this,'Unset',...
    '',slreq.datamodel.RequirementType.empty);


    addRequirementType(this,'Functional','',mfUnset);
    addRequirementType(this,'Informational','',mfUnset);
    addRequirementType(this,'Container','',mfUnset);

    function reqType=addRequirementType(this,name,description,superType)
        reqType=slreq.datamodel.RequirementType(this.model);
        reqType.name=name;
        reqType.isBuiltin=true;
        reqType.description=description;
        reqType.superType=superType;
        this.repository.requirementTypes.add(reqType);
    end
end
