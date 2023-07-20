classdef ParameterLoader<handle


    properties(Access=private)
ParamArray
    end

    methods
        function obj=ParameterLoader(fileName,sheet,simIndex,scenarioIndex,charOverrides)
            import stm.internal.Parameters.getParameterOverrideHelper;
            obj.ParamArray=getParameterOverrideHelper(fileName,sheet,...
            simIndex,scenarioIndex,charOverrides);
        end

        function out=getVariable(obj,varName,blockPath)
            try
                mask={obj.ParamArray.Name}==string(varName)&...
                {obj.ParamArray.BlockPath}==string(blockPath);
                out=obj.ParamArray(mask).Value;
            catch
                MException(message('stm:Parameters:ParameterNotFoundInMFile',varName)).throw;
            end
        end
    end
end
