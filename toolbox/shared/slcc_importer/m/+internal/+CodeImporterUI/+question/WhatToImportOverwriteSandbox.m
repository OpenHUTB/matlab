classdef WhatToImportOverwriteSandbox<internal.CodeImporterUI.QuestionBase
    methods
        function obj=WhatToImportOverwriteSandbox(env)
            id='WhatToImportOverwriteSandbox';
            topic=message('Simulink:CodeImporterUI:Topic_Analyze').getString;
            obj@internal.CodeImporterUI.QuestionBase(id,topic,env);
            obj.NextQuestionId='WhatToImportFinishSandbox';
            obj.SinglePane=true;
            obj.getAndAddOption(env,'WhatToImportOverwriteSandbox_Update');
            obj.getAndAddOption(env,'WhatToImportOverwriteSandbox_Overwrite');
            obj.HasHelp=false;
            obj.HasHintMessage=false;
        end

        function onNext(obj)
            onNext@internal.CodeImporterUI.QuestionBase(obj);
            obj.Env.Gui.MessageHandler.create_sandbox;
        end
    end
end

