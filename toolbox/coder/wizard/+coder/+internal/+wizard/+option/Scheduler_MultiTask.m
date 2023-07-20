


classdef Scheduler_MultiTask<coder.internal.wizard.OptionBase
    methods
        function obj=Scheduler_MultiTask(env)
            id='Scheduler_MultiTask';
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
            if~strcmp(env.getParam('SolverType'),'Fixed-step')
                env.setParamRequired('SolverType','Fixed-step');
            end


            env.setParamRequired('SampleTimeConstraint','Unconstrained');
            env.setParamRequired('SolverMode','Auto');



            env.setParamRequired('AutoInsertRateTranBlk','on');
            obj.NextQuestion_Id=coder.internal.wizard.question.Scheduler.getNextQuestionId(env);
        end
    end
end


