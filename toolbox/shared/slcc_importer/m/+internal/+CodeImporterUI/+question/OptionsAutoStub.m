

classdef OptionsAutoStub<internal.CodeImporterUI.QuestionBase
    methods
        function obj=OptionsAutoStub(env)
            id='OptionsAutoStub';
            topic=message('Simulink:CodeImporterUI:Topic_Options').getString;
            obj@internal.CodeImporterUI.QuestionBase(id,topic,env);
            obj.NextQuestionId='Finish';
            obj.getAndAddOption(env,'OptionsAutoStub_Checkbox');
            obj.getAndAddOption(env,'OptionsAggregateHeader_Checkbox');
            obj.HasSummaryMessage=false;
        end
    end
end
