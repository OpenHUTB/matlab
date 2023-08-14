


classdef Flavor_Autosar_Adaptive<coder.internal.wizard.OptionBase
    methods
        function obj=Flavor_Autosar_Adaptive(env)
            id='Flavor_Autosar_Adaptive';
            obj@coder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Analyze';
            obj.Type='radio';
            obj.Value=false;
            obj.DepInfo=struct('Option','System_Model','Value',true);
        end



        function out=isEnabled(obj)
            out=isEnabled@coder.internal.wizard.OptionBase(obj);
            out=out&&autosarinstalled();
        end
        function onNext(obj)
            env=obj.Env;
            env.setParamRequired('SystemTargetFile','autosar_adaptive.tlc');
            if~strcmp(get_param(env.ModelName,'SolverType'),'Fixed-step')
                env.setParamRequired('SolverType','Fixed-step');
            end
            env.setParamRequired('SampleTimeConstraint','Unconstrained');
            env.Flavor='AUTOSAR_Adaptive';
        end
    end
end
