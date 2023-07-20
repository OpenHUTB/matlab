function tgtPackedDataType=getTgtPackedDataType(typeString,packedDataTypes)
    tgtPackedDataType=[];
    for i=1:length(packedDataTypes)
        if strcmp(packedDataTypes(i).TypeName,typeString)
            tgtPackedDataType=packedDataTypes(i);
        end
    end
end