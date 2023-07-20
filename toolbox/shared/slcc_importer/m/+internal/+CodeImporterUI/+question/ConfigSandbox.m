classdef ConfigSandbox<internal.CodeImporterUI.QuestionBase
    methods
        function obj=ConfigSandbox(env)
            id='ConfigSandbox';
            topic=message('Simulink:CodeImporterUI:Topic_Analyze').getString;
            obj@internal.CodeImporterUI.QuestionBase(id,topic,env);
            obj.NextQuestionId='WhatToImportAnalyzeSandbox';
            obj.getAndAddOption(env,'ConfigSandbox_AggregatedHeader');
            obj.getAndAddOption(env,'ConfigSandbox_PreprocessedSource');
            obj.getAndAddOption(env,'ConfigSandbox_UseOriginalCode');
        end

        function onNext(obj)
            onNext@internal.CodeImporterUI.QuestionBase(obj);
        end
    end
end

