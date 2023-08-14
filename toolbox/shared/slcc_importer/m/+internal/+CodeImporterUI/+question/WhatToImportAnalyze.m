

classdef WhatToImportAnalyze<internal.CodeImporterUI.QuestionBase
    methods
        function obj=WhatToImportAnalyze(env)
            id='WhatToImportAnalyze';
            topic=message('Simulink:CodeImporterUI:Topic_Analyze').getString;
            obj@internal.CodeImporterUI.QuestionBase(id,topic,env);
            obj.NextQuestionId='WhatToImportFunction';
            obj.getAndAddOption(env,'WhatToImportAnalyze_Run');
            obj.HasHelp=false;
            obj.SinglePane=true;
            obj.HasHintMessage=false;
            obj.HasNext=true;
        end

        function onNext(obj)
            onNext@internal.CodeImporterUI.QuestionBase(obj);
            env=obj.Env;

            env.Gui.MessageHandler.analyze;
            parseInfo=env.CodeImporter.ParseInfo;
            assert(~isempty(parseInfo));

            if parseInfo.hasGlobalVariable()
                obj.NextQuestionId='OptionsGlobalIO';
            else
                obj.NextQuestionId='WhatToImportFunction';
            end
        end
    end
end

