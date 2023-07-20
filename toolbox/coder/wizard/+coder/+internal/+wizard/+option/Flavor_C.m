


classdef Flavor_C<coder.internal.wizard.OptionBase
    methods
        function obj=Flavor_C(env)
            id='Flavor_C';
            obj@coder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Analyze';
            obj.Type='radio';
            obj.Value=false;
            obj.DepInfo='';
        end
        function onNext(obj)
            env=obj.Env;
            env.CSM.SwitchToERT;
            env.setParamRequired('TargetLang','C');
            env.setMultiInstance();

            env.Flavor='C';
        end
    end
end
