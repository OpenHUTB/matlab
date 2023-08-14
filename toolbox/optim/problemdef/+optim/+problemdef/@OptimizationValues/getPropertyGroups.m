function groups=getPropertyGroups(obj)











    [strongStartTag,strongEndTag]=optim.internal.problemdef.createStrongTags;
    variablesHeader=getString(message('optim_problemdef:OptimizationValues:getPropertyGroups:VariablesHeader',...
    strongStartTag,strongEndTag));
    objectiveHeader=getString(message('optim_problemdef:OptimizationValues:getPropertyGroups:ObjectiveHeader',...
    strongStartTag,strongEndTag));
    constraintsHeader=getString(message('optim_problemdef:OptimizationValues:getPropertyGroups:ConstraintsHeader',...
    strongStartTag,strongEndTag));


    varNames=fieldnames(obj.VariableSize);
    objNames=fieldnames(obj.ObjectiveSize);
    conNames=fieldnames(obj.ConstraintSize);


    variableValues=iCreateDataStructure(obj,[objNames;conNames]);


    objectiveValues=iCreateDataStructure(obj,[varNames;conNames]);


    groups(1)=matlab.mixin.util.PropertyGroup(variableValues,variablesHeader);
    groups(2)=matlab.mixin.util.PropertyGroup(objectiveValues,objectiveHeader);
    if iGetNumConstraints(obj.ConstraintSize)>0


        constraintValues=iCreateDataStructure(obj,[varNames;objNames]);


        groups(3)=matlab.mixin.util.PropertyGroup(constraintValues,constraintsHeader);
    end

end

function valsStruct=iCreateDataStructure(obj,otherNames)

    valsStruct=obj.Values;
    valsStruct=rmfield(valsStruct,otherNames);

end

function nCon=iGetNumConstraints(constraintSize)

    nCon=sum(structfun(@prod,constraintSize));

end
