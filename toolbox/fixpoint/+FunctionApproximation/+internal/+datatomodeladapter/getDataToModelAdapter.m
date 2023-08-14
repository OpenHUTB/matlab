function adapter=getDataToModelAdapter(data)





    adapter=[];
    if isa(data,'FunctionApproximation.internal.serializabledata.BlockData')
        adapter=FunctionApproximation.internal.datatomodeladapter.BlockDataToModel();
    elseif isa(data,'FunctionApproximation.internal.serializabledata.LUTModelData')
        if data.HDLOptimized
            if data.NumberOfDimensions==1
                adapter=FunctionApproximation.internal.datatomodeladapter.HDLLUTModelDataToModelFor1D();
            end
        else
            adapter=FunctionApproximation.internal.datatomodeladapter.LUTModelDataToModel();
        end
    elseif isa(data,'FunctionApproximation.internal.serializabledata.DirectLUData')
        adapter=FunctionApproximation.internal.datatomodeladapter.DirectLUDataToModel();
    end
end
