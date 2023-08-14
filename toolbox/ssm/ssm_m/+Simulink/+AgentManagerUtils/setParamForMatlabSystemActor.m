function setParamForMatlabSystemActor(sysObj,modelArgs)

    if(isempty(sysObj)||isempty(modelArgs))
        return;
    end

    try
        for i=1:numel(modelArgs)
            paramName=modelArgs(i).name;
            try
                paramVal=evalin('caller',modelArgs(i).value);
            catch ME

                if ischar(modelArgs(i).value)||isstring(modelArgs(i).value)
                    paramVal=modelArgs(i).value;
                else
                    rethrow(ME);
                end
            end
            sysObj.(paramName)=paramVal;
        end
    catch ME
        warning("Failed to set parameter '%s' for class '%s'",paramName,class(sysObj));
        rethrow(ME);
    end

end