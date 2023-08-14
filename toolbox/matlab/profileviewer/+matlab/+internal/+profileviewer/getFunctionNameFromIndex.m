function functionName=getFunctionNameFromIndex(functionTable,functionIndex,summaryFunctionIndex)




    if isequal(functionIndex,summaryFunctionIndex)
        functionName='';
        return
    end
    functionTableItem=functionTable(...
    cellfun(@(x)isequal(x,functionIndex),{functionTable.FunctionIndex}));
    if isempty(functionTableItem)
        error(message('MATLAB:profiler:FunctionNotFound',functionIndex))
    end
    functionName=functionTableItem.FunctionName;
end
