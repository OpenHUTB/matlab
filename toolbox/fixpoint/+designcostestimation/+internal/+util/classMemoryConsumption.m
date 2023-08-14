function[memoryConsumption]=classMemoryConsumption(Parameter)



    Elements=Parameter.Elements;
    memoryConsumption=0;
    for elementIdx=1:numel(Elements)
        memoryConsumption=(Elements(elementIdx).Type.BaseType.WordLength)/8+memoryConsumption;
    end
end
