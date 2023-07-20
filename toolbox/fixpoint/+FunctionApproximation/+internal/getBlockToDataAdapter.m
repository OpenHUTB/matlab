function blockToDataAdapter=getBlockToDataAdapter(compileModel,modelCompiled)










    if nargin==1
        modelCompiled=false;
    end

    if modelCompiled
        blockToDataAdapter=FunctionApproximation.internal.serializabledata.BlockDataAssumeCompile();
    else
        if compileModel
            blockToDataAdapter=FunctionApproximation.internal.serializabledata.BlockDataWithCompile();
        else
            blockToDataAdapter=FunctionApproximation.internal.serializabledata.BlockDataWithoutCompile();
        end
    end
end


