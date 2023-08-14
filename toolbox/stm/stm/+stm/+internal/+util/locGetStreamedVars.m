

function vars=locGetStreamedVars(sigLoggingName,outportLoggingName,codeExecutionProfileVarName,dsmLoggingName,stateName)
    vars={sigLoggingName,outportLoggingName,dsmLoggingName,stateName};
    if~isempty(codeExecutionProfileVarName)
        vars{end+1}=codeExecutionProfileVarName;
    end
end

