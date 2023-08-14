classdef WhatToImportAnalyzeSandbox_Option<internal.CodeImporterUI.OptionBase
    methods
        function obj=WhatToImportAnalyzeSandbox_Option(env)
            id='WhatToImportAnalyzeSandbox_Option';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='hidden';
            obj.Value=true;
            obj.Answer=true;
            obj.HasMessage=false;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
        end

        function onNext(obj)

        end
    end
end

