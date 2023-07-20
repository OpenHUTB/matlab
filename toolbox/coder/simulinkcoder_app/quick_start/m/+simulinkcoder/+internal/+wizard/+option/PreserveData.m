

classdef PreserveData<simulinkcoder.internal.wizard.OptionBase
    methods
        function obj=PreserveData(env)
            id='PreserveData';
            obj@simulinkcoder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Finish';
            obj.Type='subquestion';
            obj.Value=message(['SimulinkCoderApp:wizard:Option_',id]).getString;
            obj.Answer=false;

            obj.HasHintMessage=false;
            obj.DepInfo=struct('Option','Optimization_Execution','Value',true);
        end
        function onNext(obj)
            if obj.Answer
                obj.Env.PreserveNamedSignal=true;
            else
                obj.Env.PreserveNamedSignal=false;
            end
        end
    end
end


