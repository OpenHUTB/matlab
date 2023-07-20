

classdef PreserveParameter<simulinkcoder.internal.wizard.OptionBase
    methods
        function obj=PreserveParameter(env)
            id='PreserveParameter';
            obj@simulinkcoder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Finish';
            obj.Type='checkbox';
            obj.Value=false;
            obj.Answer=false;
            obj.HasHintMessage=false;
            obj.DepInfo=struct('Option','Optimization_Execution','Value',true);
        end
        function onNext(obj)
            if obj.Answer
                obj.Env.PreserveParameter=true;
            else
                obj.Env.PreserveParameter=false;
            end
        end
    end
end