

classdef OptionsGlobalIO<internal.CodeImporterUI.QuestionBase
    methods
        function obj=OptionsGlobalIO(env)
            id='OptionsGlobalIO';
            topic=message('Simulink:CodeImporterUI:Topic_Analyze').getString;
            obj@internal.CodeImporterUI.QuestionBase(id,topic,env);


            obj.NextQuestionId='WhatToImportFunction';
            obj.getAndAddOption(env,'OptionsGlobalIO_Checkbox');
            obj.HasSummaryMessage=false;
        end

        function preShow(obj)
            preShow@internal.CodeImporterUI.QuestionBase(obj);
            globalIOText=message('RTW:configSet:CustomCodeGlobalsAsFunctionIOName').getString();
            obj.HintMessage=message(...
            'Simulink:CodeImporterUI:QuestionHint_OptionsGlobalIO',globalIOText).getString();
        end
    end
end

