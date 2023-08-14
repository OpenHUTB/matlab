
classdef WhatToImportFunction_FunctionNameFilter<internal.CodeImporterUI.OptionBase
    methods
        function obj=WhatToImportFunction_FunctionNameFilter(env)
            id='WhatToImportFunction_FunctionNameFilter';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='user_input';
            obj.Property='UserInputFunctionFilter';
            obj.HasMessage=false;
            obj.HasHintMessage=true;
            obj.HasSummaryMessage=false;
            obj.Answer="";
        end
    end
end

