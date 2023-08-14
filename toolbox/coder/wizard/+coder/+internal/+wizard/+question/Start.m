


classdef Start<coder.internal.wizard.QuestionBase
    methods
        function obj=Start(env)
            id='Start';
            topic=message('RTW:wizard:Topic_Welcome').getString;
            obj@coder.internal.wizard.QuestionBase(id,topic,env);
            obj.HasHelp=false;
            obj.SinglePane=true;
            obj.CountInProgress=false;
            obj.HasBack=false;
            obj.getAndAddOption(env,'Start_Continue');
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
            obj.MsgParam={env.ModelName};
        end
    end
end


