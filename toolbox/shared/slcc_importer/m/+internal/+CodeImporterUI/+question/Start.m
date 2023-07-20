

classdef Start<internal.CodeImporterUI.QuestionBase
    methods
        function obj=Start(env)
            id='Start';
            topic=message('Simulink:CodeImporterUI:Topic_Welcome').getString;
            obj@internal.CodeImporterUI.QuestionBase(id,topic,env);
            obj.HasHelp=false;
            obj.NextQuestionId='ConfigCodeImporter';
            obj.SinglePane=true;
            obj.CountInProgress=false;
            obj.HasBack=false;
            obj.HasStartNew=true;
            obj.HasLoad=true;
            obj.HasNext=false;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
            obj.MsgParam={};
        end

        function preShow(obj)
            if obj.Env.CodeImporter.isSLTest
                obj.QuestionMessage=message(...
                'Simulink:CodeImporterUI:Question_Start_SLTest').getString();
            end
        end

        function onNext(obj)
            onNext@internal.CodeImporterUI.QuestionBase(obj);
        end

    end
end


