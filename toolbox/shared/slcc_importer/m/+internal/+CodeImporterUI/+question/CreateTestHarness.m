classdef CreateTestHarness<internal.CodeImporterUI.QuestionBase
    methods
        function obj=CreateTestHarness(env)
            id='CreateTestHarness';
            topic=message('Simulink:CodeImporterUI:Topic_Finish').getString;
            obj@internal.CodeImporterUI.QuestionBase(id,topic,env);
            obj.NextQuestionId='NextStep';
            obj.SinglePane=true;
            obj.getAndAddOption(env,'CreateTestHarness_Auto');
            obj.getAndAddOption(env,'CreateTestHarness_Skip');
            obj.HasHintMessage=false;
            obj.HasHelp=false;
        end

        function onNext(obj)
            env=obj.Env;
            env.Gui.MessageHandler.create;
            if env.CodeImporter.Options.CreateTestHarness
                callback=@()myFuncExecutesAfterSltestManagerRendered(obj);
                sltest.internal.invokeFunctionAfterWindowRenders(callback);
            else
                env.Gui.Dlg.show;
            end
        end

        function myFuncExecutesAfterSltestManagerRendered(obj)
            obj.Env.Gui.Dlg.show;
        end
    end
end

