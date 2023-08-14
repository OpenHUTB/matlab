function[memoryConsumption,blockName]=paramMemoryConsumption(Parameter,isInlined)




    switch class(Parameter.Type)
    case 'coder.descriptor.types.Matrix'
        memoryConsumption=designcostestimation.internal.util.matrixMemoryConsumption(Parameter);
    case 'coder.descriptor.types.Struct'
        memoryConsumption=designcostestimation.internal.util.structMemoryConsumption(Parameter.Type);
    case 'coder.descriptor.types.Complex'
        memoryConsumption=designcostestimation.internal.util.complexMemoryConsumption(Parameter.Type);
    case 'coder.descriptor.types.Class'
        memoryConsumption=designcostestimation.internal.util.classMemoryConsumption(Parameter.Type);
    otherwise
        memoryConsumption=designcostestimation.internal.util.builtinsMemoryConsumption(Parameter);
    end
    if(isInlined)
        blockName=Parameter.Path;
    elseif contains(Parameter.SID,'#var:')
        variableName=extractAfter(Parameter.SID,'#var:');
        blockName="ModelWorkspaceParam: "+variableName;
    elseif~(isempty(Parameter.SID))
        blockName=Simulink.ID.getFullName(Parameter.SID);
    else
        blockName="BaseWorkspaceParam: "+Parameter.GraphicalName;
    end
end
