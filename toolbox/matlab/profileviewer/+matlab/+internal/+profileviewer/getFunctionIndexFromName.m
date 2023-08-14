function functionIndex=getFunctionIndexFromName(functionTable,functionName,summaryFunctionIndex)




    functionIndex=summaryFunctionIndex;
    if isnumeric(functionName)
        validateattributes(functionName,{'numeric'},{'nonempty','scalar',...
        'integer','>=',0,'<=',numel(functionTable)});
        functionIndex=functionName;
        return;
    end

    if ischar(functionName)||isstring(functionName)
        functionNameList={functionTable.FunctionName};
        searchIndex=find(strcmp(functionNameList,functionName)==1);
        if isempty(searchIndex)
            error(message('MATLAB:profiler:FunctionNotFound',functionName))
        end
        functionIndex=functionTable(searchIndex).FunctionIndex;
    end
end
