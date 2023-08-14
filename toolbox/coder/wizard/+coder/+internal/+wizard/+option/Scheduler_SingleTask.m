


classdef Scheduler_SingleTask<coder.internal.wizard.OptionBase
    methods
        function obj=Scheduler_SingleTask(env)
            id='Scheduler_SingleTask';
            obj@coder.internal.wizard.OptionBase(id,env);
            if slfeature('QuickStartProfile')
                obj.NextQuestion_Id='MappingProfileCustomization';
            else
                obj.NextQuestion_Id='Wordsize';
            end
            obj.Type='radio';
            obj.Value=false;
        end
        function onNext(obj)
            env=obj.Env;
            coder.internal.wizard.option.Scheduler_SingleTask.OnNext(env);
            obj.NextQuestion_Id=coder.internal.wizard.question.Scheduler.getNextQuestionId(env);
        end
    end
    methods(Static)
        function OnNext(env)

            if~strcmp(env.getParam('SolverType'),'Fixed-step')
                env.setParamRequired('SolverType','Fixed-step');
            end

            env.setParamRequired('SampleTimeConstraint','Unconstrained');
            if env.ExportedFunctionCalls
                env.setParamRequired('SolverMode','Auto');
            else
                env.setParamRequired('SolverMode','SingleTasking');
            end
        end
    end
end


