function tgtSimdType=getPackedTypeForApi(typeString,simdApi)
    tgtSimdType=[];
    dataTypes=simdApi.DataTypes;
    for i=1:length(dataTypes)
        if isa(dataTypes(i),'target.internal.PackedDataType')&&strcmp(dataTypes(i).TypeName,typeString)
            tgtSimdType=dataTypes(i);
            return;
        end
    end
end