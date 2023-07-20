


classdef Scheduler_SingleTaskCpp<coder.internal.wizard.OptionBase
    methods
        function obj=Scheduler_SingleTaskCpp(env)
            id='Scheduler_SingleTaskCpp';
            obj@coder.internal.wizard.OptionBase(id,env);
            if slfeature('QuickStartProfile')
                obj.NextQuestion_Id='MappingProfileCustomization';
            else
                obj.NextQuestion_Id='Wordsize';
            end
            obj.Type='hidden';
            obj.Value=true;
            obj.Answer=true;
            obj.HasMessage=false;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
        end
        function onNext(obj)
            env=obj.Env;
            if strcmp(env.getParam('SolverType'),'Variable-step')
                env.setParamRequired('SolverType','Fixed-step');
            end

            env.setParamRequired('SampleTimeConstraint','Unconstrained');
            if env.ExportedFunctionCalls
                env.setParamRequired('SolverMode','Auto');
            else
                env.setParamRequired('SolverMode','SingleTasking');
            end
            obj.NextQuestion_Id=coder.internal.wizard.question.Scheduler.getNextQuestionId(env);
        end
    end
end


