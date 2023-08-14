classdef(Abstract)LUTScriptFactory<handle



    methods(Abstract)
        getBreakpointValuesString(this,context);

        getTableValuesString(this,context);

        getCommentstoAddString(function_name,commentsToAdd);

        getIndexTypeString(inputType);

        getStringsForOutputType(outputType);

        getTableValuesContext();

        getBreakpointValuesContext();

        getInterpolationStrategyContext();

    end
end