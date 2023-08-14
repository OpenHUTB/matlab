


classdef Scheduler_SingleRate<coder.internal.wizard.OptionBase
    methods
        function obj=Scheduler_SingleRate(env)
            id='Scheduler_SingleRate';
            obj@coder.internal.wizard.OptionBase(id,env);
            if slfeature('QuickStartProfile')
                obj.NextQuestion_Id='MappingProfileCustomization';
            else
                obj.NextQuestion_Id='Wordsize';
            end
            obj.Type='hidden';
            obj.Value=true;
        end
        function onNext(obj)
            env=obj.Env;
            obj.NextQuestion_Id=coder.internal.wizard.question.Scheduler.getNextQuestionId(env);
        end
    end
end


