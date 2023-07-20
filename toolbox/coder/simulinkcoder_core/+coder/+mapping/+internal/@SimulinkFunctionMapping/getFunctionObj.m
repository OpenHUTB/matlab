function out=getFunctionObj(cTargetMapping,fcnName)




    if isempty(cTargetMapping)

        out=[];
    else
        out=findobj(cTargetMapping.SimulinkFunctionCallerMappings,...
        'SimulinkFunctionName',fcnName);
    end
end
