function lutBlockToDataAdapter=getLUTBlockToDataAdapter(compileModel,modelCompiled)










    if nargin==1
        modelCompiled=false;
    end

    if modelCompiled
        lutBlockToDataAdapter=FunctionApproximation.internal.serializabledata.LUTBlockToDataAdapterAssumeModelCompile();
    else
        if compileModel
            lutBlockToDataAdapter=FunctionApproximation.internal.serializabledata.LUTBlockToDataAdapterWithModelCompile();
        else
            lutBlockToDataAdapter=FunctionApproximation.internal.serializabledata.LUTBlockToDataAdapterWithoutModelCompile();
        end
    end
end


