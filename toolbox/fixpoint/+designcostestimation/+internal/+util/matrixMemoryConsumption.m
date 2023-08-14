function[memoryConsumption]=matrixMemoryConsumption(Parameter)




    switch class(Parameter.Type.BaseType)
    case 'coder.descriptor.types.Struct'
        numBytes=designcostestimation.internal.util.structMemoryConsumption(Parameter.Type.BaseType);
    case 'coder.descriptor.types.Complex'
        numBytes=designcostestimation.internal.util.complexMemoryConsumption(Parameter.Type.BaseType);
    otherwise
        numBytes=(Parameter.Type.BaseType.WordLength)/8;
    end
    numDimensions=1;
    dimVals=Parameter.Type.Dimensions.toArray;
    for i=1:numel(dimVals)
        numDimensions=dimVals(i)*numDimensions;
    end
    memoryConsumption=numDimensions*numBytes;
end
