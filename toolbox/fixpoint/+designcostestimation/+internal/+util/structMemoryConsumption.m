function[memoryConsumption]=structMemoryConsumption(Parameter)




    Elements=Parameter.Elements;
    memoryConsumption=0;
    for elementIdx=1:numel(Elements)
        switch class(Elements(elementIdx).Type)
        case 'coder.descriptor.types.Matrix'
            memoryConsumption=designcostestimation.internal.util.matrixMemoryConsumption(Elements(elementIdx))+memoryConsumption;
        case 'coder.descriptor.types.Struct'
            memoryConsumption=designcostestimation.internal.util.structMemoryConsumption(Elements(elementIdx).Type)+memoryConsumption;
        case 'coder.descriptor.types.Complex'
            memoryConsumption=designcostestimation.internal.util.complexMemoryConsumption(Elements(elementIdx).Type)+memoryConsumption;
        case 'coder.descriptor.types.Class'
            memoryConsumption=designcostestimation.internal.util.classMemoryConsumption(Elements(elementIdx).Type)+memoryConsumption;
        otherwise
            memoryConsumption=designcostestimation.internal.util.builtinsMemoryConsumption(Elements(elementIdx))+memoryConsumption;
        end
    end
end
