


classdef Flavor_C<simulinkcoder.internal.wizard.OptionBase
    methods
        function obj=Flavor_C(env)
            id='Flavor_C';
            obj@simulinkcoder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Optimization';
            obj.Type='radio';
            obj.Value=false;
            obj.DepInfo='';
        end
        function onNext(obj)
            env=obj.Env;
            env.CSM.SwitchToGRT;
            env.setParamRequired('TargetLang','C');
            env.setMultiInstance();

            env.Flavor='C';
        end
    end
end
