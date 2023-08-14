function result=getArgTypes(testName,entryPointNames,varargin)

































    try
        coder.internal.ddux.logger.logCoderEventData("coderGetArgTypesCli");
        result=coder.internal.getArgTypes(testName,entryPointNames,varargin{:});
    catch ME
        ME.throwAsCaller();
    end
end

