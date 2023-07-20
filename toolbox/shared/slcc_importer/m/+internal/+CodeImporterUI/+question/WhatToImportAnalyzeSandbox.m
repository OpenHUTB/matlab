classdef WhatToImportAnalyzeSandbox<internal.CodeImporterUI.QuestionBase
    methods
        function obj=WhatToImportAnalyzeSandbox(env)
            id='WhatToImportAnalyzeSandbox';
            topic=message('Simulink:CodeImporterUI:Topic_Analyze').getString;
            obj@internal.CodeImporterUI.QuestionBase(id,topic,env);
            obj.getAndAddOption(env,'WhatToImportAnalyzeSandbox_Option');

            obj.HasHelp=false;
            obj.SinglePane=true;
            obj.HasHintMessage=false;
        end

        function onNext(obj)
            onNext@internal.CodeImporterUI.QuestionBase(obj);
            env=obj.Env;

            assert(env.IsSLTest&&obj.Env.CodeImporter.TestType==...
            internal.CodeImporter.TestTypeEnum.UnitTest);






            if exist(env.CodeImporter.SandboxPath,'dir')==7
                obj.NextQuestionId='WhatToImportOverwriteSandbox';
            else


                obj.Env.Gui.MessageHandler.create_sandbox;
                obj.NextQuestionId='WhatToImportFinishSandbox';
            end
        end
    end
end

