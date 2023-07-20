
classdef WhatToImportType_TypeNameFilter<internal.CodeImporterUI.OptionBase
    methods
        function obj=WhatToImportType_TypeNameFilter(env)
            id='WhatToImportType_TypeNameFilter';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='user_input';
            obj.Property='UserInputTypeFilter';
            obj.HasMessage=false;
            obj.HasHintMessage=true;
            obj.HasSummaryMessage=false;
            obj.Answer="";
        end
    end
end

