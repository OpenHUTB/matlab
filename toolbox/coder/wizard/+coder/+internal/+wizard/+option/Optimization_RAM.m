classdef Optimization_RAM<coder.internal.wizard.OptionBase




    methods
        function obj=Optimization_RAM(env)
            id='Optimization_RAM';
            obj@coder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Finish';
            obj.Type='radio';
            obj.Value=false;
        end
        function onNext(obj)
            env=obj.Env;
            env.setCommonOptimization();
            env.setCommonSettings();
            env.setParamOptional('BooleansAsBitfields','on');
            env.setParamOptional('DataBitsets','on');
            env.setParamOptional('StateBitsets','on');
            env.setParamOptional('GlobalVariableUsage','Use global to hold temporary results');


            if isempty(env.getParam('ObjectivePriorities'))
                env.setParamOptional('ObjectivePriorities',{{'RAM efficiency','Execution efficiency'}});
            end
        end
    end
end


