

classdef ConfigUpdateMode<internal.CodeImporterUI.QuestionBase
    methods
        function obj=ConfigUpdateMode(env)
            id='ConfigUpdateMode';
            topic=message('Simulink:CodeImporterUI:Topic_Finish').getString;
            obj@internal.CodeImporterUI.QuestionBase(id,topic,env);
            obj.NextQuestionId='NextStep';
            obj.SinglePane=true;
            obj.getAndAddOption(env,'ConfigUpdateMode_UpdateExisting');
            obj.getAndAddOption(env,'ConfigUpdateMode_Overwrite');
            obj.HasHelp=false;
            obj.HasHintMessage=false;
        end

        function onNext(obj)


            if obj.Env.CodeImporter.HasSLTest
                obj.NextQuestionId='CreateTestHarness';
            else
                obj.Env.Gui.MessageHandler.create;
            end

        end
    end
end


