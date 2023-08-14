


classdef StartWithError<coder.internal.wizard.QuestionBase
    methods
        function obj=StartWithError(env)
            id='StartWithError';
            topic=message('RTW:wizard:Topic_Welcome').getString;
            obj@coder.internal.wizard.QuestionBase(id,topic,env);
            obj.HasHelp=false;
            obj.SinglePane=true;
            obj.CountInProgress=false;
            obj.HasBack=false;

            obj.getAndAddOption(env,'StartWithError_Continue');
            obj.MsgParam={env.ModelName};
            obj.QuestionMessage=message('RTW:wizard:Question_Start',obj.MsgParam{:}).getString;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
        end
    end
end
