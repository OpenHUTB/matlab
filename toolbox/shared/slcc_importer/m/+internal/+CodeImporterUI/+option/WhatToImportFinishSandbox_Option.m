classdef WhatToImportFinishSandbox_Option<internal.CodeImporterUI.OptionBase
    methods
        function obj=WhatToImportFinishSandbox_Option(env)
            id='WhatToImportFinishSandbox_Option';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='hidden';
            obj.Value='Update';
            obj.Answer=true;
            obj.HasMessage=false;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
        end
    end
end

