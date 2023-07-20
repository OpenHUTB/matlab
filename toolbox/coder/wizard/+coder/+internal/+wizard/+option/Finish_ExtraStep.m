classdef Finish_ExtraStep<coder.internal.wizard.OptionBase
    methods
        function obj=Finish_ExtraStep(env)
            id='Finish_ExtraStep';
            obj@coder.internal.wizard.OptionBase(id,env);
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
