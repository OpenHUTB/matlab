function adapter=getDataToScriptAdapter(data)





    adapter=[];
    if isa(data,'FunctionApproximation.internal.serializabledata.InterpNData')
        adapter=FunctionApproximation.internal.datatomodeladapter.LUTModelDataToScriptAdapter(data);
    end
end
