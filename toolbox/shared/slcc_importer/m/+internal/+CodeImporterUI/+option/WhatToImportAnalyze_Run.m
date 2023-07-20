classdef WhatToImportAnalyze_Run<internal.CodeImporterUI.OptionBase
    methods
        function obj=WhatToImportAnalyze_Run(env)
            id='WhatToImportAnalyze_Run';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='hidden';
            obj.Value=true;
            obj.Answer=true;
            obj.HasMessage=false;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
        end
    end
end