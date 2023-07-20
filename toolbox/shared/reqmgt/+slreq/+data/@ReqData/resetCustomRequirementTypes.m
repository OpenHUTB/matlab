function count=resetCustomRequirementTypes(this)







    reqTypes=this.repository.requirementTypes;
    typeNames=reqTypes.keys();
    count=0;
    for i=1:numel(typeNames)
        oneType=reqTypes{typeNames{i}};
        if~oneType.isBuiltin
            oneType.destroy();
            count=count+1;
        end
    end
end
