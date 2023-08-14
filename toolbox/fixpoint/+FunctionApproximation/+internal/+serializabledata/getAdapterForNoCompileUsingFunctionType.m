function adapter=getAdapterForNoCompileUsingFunctionType(functionType)




    adapter=FunctionApproximation.internal.serializabledata.SerializableData.empty();
    if isBlock(functionType)
        adapter=FunctionApproximation.internal.serializabledata.BlockDataWithoutCompile();
        if functionType=="LUTBlock"
            adapter=FunctionApproximation.internal.serializabledata.LUTBlockToDataAdapterWithoutModelCompile();
        end
    end
end