classdef Finish_ExtraStep<simulinkcoder.internal.wizard.OptionBase
    methods
        function obj=Finish_ExtraStep(env)
            id='Finish_ExtraStep';
            obj@simulinkcoder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Additional';
            obj.Type='hidden';
            obj.Value=true;
            obj.Answer=true;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
        end
        function onNext(~)
        end
    end
end
