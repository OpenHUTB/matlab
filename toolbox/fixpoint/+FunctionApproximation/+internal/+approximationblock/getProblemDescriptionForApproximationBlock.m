function description=getProblemDescriptionForApproximationBlock(problemDefinition)






    problemStruct=FunctionApproximation.internal.Utils.getStructFromProblem(problemDefinition);
    description='Inputs for approximation:';
    baseFormat='%s\n  %s';
    names=fieldnames(problemStruct);
    names=setdiff(names,'Options');
    for iName=1:numel(names)
        currentName=names{iName};
        if~ismember(currentName,["FunctionToReplace","InputFunctionType","FunctionToApproximate","StorageTypes"])
            description=sprintf([baseFormat,': %s'],description,currentName,sprintf('%s ',problemStruct.(currentName)));
        end
    end

    names=fieldnames(problemStruct.Options);
    defaultFields=setdiff(problemDefinition.Options.DefaultFields,{'AbsTol','RelTol'});
    names=setdiff(names,defaultFields);
    baseFormatOptions='%s\n    %s';
    description=sprintf(baseFormat,description,['Options ',message('SimulinkFixedPoint:functionApproximation:rfabOthersAreDefault').getString()]);
    for iName=1:numel(names)
        currentName=names{iName};
        description=sprintf([baseFormatOptions,': %s'],description,currentName,sprintf('%s ',problemStruct.Options.(currentName)));
    end
end


